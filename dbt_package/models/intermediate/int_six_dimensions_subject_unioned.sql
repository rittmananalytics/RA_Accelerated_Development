{{
    config(
        materialized='view',
        tags=['intermediate', 'external_benchmark']
    )
}}

{#-
Unions subject-level performance data from VA, Sixth Sense, and Vocational reports.
-#}

with va_subject as (

    select
        academic_year_id,
        'VA'                                            as report_type,
        subject_name                                    as six_dimensions_subject_name,
        cast(null as string)                            as qualification_type,
        cohort_count,
        pass_rate_pct,
        high_grade_rate_pct,
        average_points                                  as average_grade_points,
        va_score,
        va_residual,
        va_band,
        va_percentile,
        va_confidence_lower,
        va_confidence_upper,
        cast(null as numeric)                           as national_pass_rate_pct,
        cast(null as numeric)                           as national_high_grade_pct,
        cast(null as numeric)                           as national_va_average,
        national_percentile                             as percentile_rank,
        national_rank                                   as subject_rank_national,
        report_filename,
        report_date,
        record_source,
        loaded_at

    from {{ ref('stg_six_dimensions__va') }}
    where level = 'Subject'
      and subject_name is not null

),

sixth_sense_subject as (

    select
        academic_year_id,
        'Sixth Sense'                                   as report_type,
        subject_name                                    as six_dimensions_subject_name,
        qualification_type,
        cohort_count,
        pass_rate_pct,
        high_grade_rate_pct,
        average_points                                  as average_grade_points,
        va_score,
        cast(null as numeric)                           as va_residual,
        va_band,
        cast(null as numeric)                           as va_percentile,
        cast(null as numeric)                           as va_confidence_lower,
        cast(null as numeric)                           as va_confidence_upper,
        national_pass_rate_pct,
        national_high_grade_pct,
        cast(null as numeric)                           as national_va_average,
        percentile_rank,
        cast(null as int64)                             as subject_rank_national,
        report_filename,
        report_date,
        record_source,
        loaded_at

    from {{ ref('stg_six_dimensions__sixth_sense') }}
    where level = 'Subject'
      and subject_name is not null

),

vocational_subject as (

    select
        academic_year_id,
        'Vocational'                                    as report_type,
        subject_name                                    as six_dimensions_subject_name,
        qualification_type,
        cohort_count,
        pass_rate_pct,
        high_grade_rate_pct,
        average_points                                  as average_grade_points,
        va_score,
        cast(null as numeric)                           as va_residual,
        va_band,
        cast(null as numeric)                           as va_percentile,
        cast(null as numeric)                           as va_confidence_lower,
        cast(null as numeric)                           as va_confidence_upper,
        national_pass_rate_pct,
        national_high_grade_pct,
        cast(null as numeric)                           as national_va_average,
        percentile_rank,
        cast(null as int64)                             as subject_rank_national,
        report_filename,
        report_date,
        record_source,
        loaded_at

    from {{ ref('stg_six_dimensions__vocational') }}
    where level = 'Subject'
      and subject_name is not null

),

unioned as (

    select * from va_subject
    union all
    select * from sixth_sense_subject
    union all
    select * from vocational_subject

)

select * from unioned
