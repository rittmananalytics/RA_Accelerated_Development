{{
    config(
        materialized='view',
        tags=['staging', 'six_dimensions', 'external_benchmark']
    )
}}

with source as (

    select * from {{ source('raw_six_dimensions', 'vocational_report') }}

),

cleaned as (

    select
        -- Keys
        vocational_report_id,
        academic_year                                   as academic_year_id,
        trim(subject_name)                              as subject_name,
        trim(qualification_type)                        as qualification_type,
        trim(qualification_size)                        as qualification_size,

        -- Cohort
        safe_cast(student_count as int64)               as cohort_count,
        safe_cast(average_gcse_on_entry as numeric)     as average_gcse_on_entry,

        -- Performance metrics
        safe_cast(completion_rate_pct as numeric)       as completion_rate_pct,
        safe_cast(achievement_rate_pct as numeric)      as achievement_rate_pct,
        safe_cast(pass_rate_pct as numeric)             as pass_rate_pct,

        -- Grade distribution (BTEC-style)
        safe_cast(distinction_star_pct as numeric)      as distinction_star_pct,
        safe_cast(distinction_pct as numeric)           as distinction_pct,
        safe_cast(merit_pct as numeric)                 as merit_pct,
        safe_cast(pass_pct as numeric)                  as pass_pct,
        safe_cast(near_pass_pct as numeric)             as near_pass_pct,
        safe_cast(fail_pct as numeric)                  as fail_pct,

        -- National benchmarks
        safe_cast(national_achievement_pct as numeric)  as national_achievement_pct,
        safe_cast(national_distinction_plus_pct as numeric) as national_distinction_plus_pct,

        -- Performance band
        performance_band,

        -- Source metadata
        report_date,

        -- Metadata
        'six_dimensions'                                as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from cleaned
