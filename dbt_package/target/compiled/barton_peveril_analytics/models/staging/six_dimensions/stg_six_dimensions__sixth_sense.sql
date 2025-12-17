

with source as (

    select * from `ra-warehouse-dev`.`analytics_seed_raw_six_dimensions`.`sixth_sense_report`

),

cleaned as (

    select
        -- Keys
        sixth_sense_id,
        academic_year                                   as academic_year_id,
        trim(subject_name)                              as subject_name,
        trim(qualification_type)                        as qualification_type,

        -- Cohort
        safe_cast(student_count as int64)               as cohort_count,

        -- Performance metrics
        safe_cast(completion_rate_pct as numeric)       as completion_rate_pct,
        safe_cast(retention_rate_pct as numeric)        as retention_rate_pct,
        safe_cast(achievement_rate_pct as numeric)      as achievement_rate_pct,
        safe_cast(pass_rate_pct as numeric)             as pass_rate_pct,
        safe_cast(high_grades_pct as numeric)           as high_grades_pct,
        safe_cast(attendance_rate_pct as numeric)       as attendance_rate_pct,

        -- National benchmarks
        safe_cast(national_completion_pct as numeric)   as national_completion_pct,
        safe_cast(national_achievement_pct as numeric)  as national_achievement_pct,
        safe_cast(national_pass_pct as numeric)         as national_pass_pct,

        -- Performance quartile
        performance_quartile,

        -- Source metadata
        report_date,

        -- Metadata
        'six_dimensions'                                as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from cleaned