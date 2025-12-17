{{
    config(
        materialized='view',
        tags=['intermediate', 'external_benchmark']
    )
}}

{#-
Unions college-level performance data from VA and Sixth Sense reports.
-#}

with va_college as (

    select
        academic_year_id,
        'VA'                                            as report_type,
        subject_name                                    as report_name,
        cohort_count                                    as total_cohort_count,
        pass_rate_pct,
        high_grade_rate_pct,
        average_points                                  as average_grade_points,
        cast(null as numeric)                           as average_ucas_points,
        va_score,
        va_band,
        va_confidence_lower,
        va_confidence_upper,
        va_percentile,
        national_rank                                   as va_national_rank,
        cast(null as numeric)                           as sixth_sense_score,
        cast(null as string)                            as sixth_sense_band,
        national_percentile                             as national_percentile_rank,
        report_filename,
        report_date,
        record_source,
        loaded_at

    from {{ ref('stg_six_dimensions__va') }}
    where level = 'College'

),

sixth_sense_college as (

    select
        academic_year_id,
        'Sixth Sense'                                   as report_type,
        subject_name                                    as report_name,
        cohort_count                                    as total_cohort_count,
        pass_rate_pct,
        high_grade_rate_pct,
        average_points                                  as average_grade_points,
        cast(null as numeric)                           as average_ucas_points,
        va_score,
        va_band,
        cast(null as numeric)                           as va_confidence_lower,
        cast(null as numeric)                           as va_confidence_upper,
        cast(null as numeric)                           as va_percentile,
        cast(null as int64)                             as va_national_rank,
        sixth_sense_score,
        sixth_sense_band,
        percentile_rank                                 as national_percentile_rank,
        report_filename,
        report_date,
        record_source,
        loaded_at

    from {{ ref('stg_six_dimensions__sixth_sense') }}
    where level = 'College'

),

unioned as (

    select * from va_college
    union all
    select * from sixth_sense_college

)

select * from unioned
