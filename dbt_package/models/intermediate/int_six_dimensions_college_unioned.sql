{{
    config(
        materialized='view',
        tags=['intermediate', 'external_benchmark']
    )
}}

{#-
Unions college-level performance data from VA and Sixth Sense reports.
Since the seed data doesn't have a 'level' column, we aggregate to college level.
-#}

with va_aggregated as (

    select
        academic_year_id,
        'VA'                                            as report_type,
        'College Overall'                               as report_name,
        sum(cohort_count)                               as total_cohort_count,
        avg(value_added_score)                          as avg_value_added_score,
        avg(confidence_interval_lower)                  as avg_confidence_lower,
        avg(confidence_interval_upper)                  as avg_confidence_upper,
        min(report_date)                                as report_date,
        'six_dimensions'                                as record_source,
        current_timestamp()                             as loaded_at

    from {{ ref('stg_six_dimensions__va') }}
    group by academic_year_id

),

sixth_sense_aggregated as (

    select
        academic_year_id,
        'Sixth Sense'                                   as report_type,
        'College Overall'                               as report_name,
        sum(cohort_count)                               as total_cohort_count,
        avg(pass_rate_pct)                              as avg_pass_rate_pct,
        avg(high_grades_pct)                            as avg_high_grades_pct,
        avg(completion_rate_pct)                        as avg_completion_rate_pct,
        avg(retention_rate_pct)                         as avg_retention_rate_pct,
        avg(achievement_rate_pct)                       as avg_achievement_rate_pct,
        avg(attendance_rate_pct)                        as avg_attendance_rate_pct,
        min(report_date)                                as report_date,
        'six_dimensions'                                as record_source,
        current_timestamp()                             as loaded_at

    from {{ ref('stg_six_dimensions__sixth_sense') }}
    group by academic_year_id

),

unioned as (

    select
        academic_year_id,
        report_type,
        report_name,
        total_cohort_count,
        cast(null as numeric) as avg_pass_rate_pct,
        cast(null as numeric) as avg_high_grades_pct,
        avg_value_added_score,
        avg_confidence_lower,
        avg_confidence_upper,
        cast(null as numeric) as avg_completion_rate_pct,
        cast(null as numeric) as avg_retention_rate_pct,
        cast(null as numeric) as avg_achievement_rate_pct,
        cast(null as numeric) as avg_attendance_rate_pct,
        report_date,
        record_source,
        loaded_at
    from va_aggregated

    union all

    select
        academic_year_id,
        report_type,
        report_name,
        total_cohort_count,
        avg_pass_rate_pct,
        avg_high_grades_pct,
        cast(null as numeric) as avg_value_added_score,
        cast(null as numeric) as avg_confidence_lower,
        cast(null as numeric) as avg_confidence_upper,
        avg_completion_rate_pct,
        avg_retention_rate_pct,
        avg_achievement_rate_pct,
        avg_attendance_rate_pct,
        report_date,
        record_source,
        loaded_at
    from sixth_sense_aggregated

)

select * from unioned
