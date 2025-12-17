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
        report_year                                     as academic_year_id,
        trim(dataset_name)                              as dataset_name,
        trim(level)                                     as level,
        trim(subject_name)                              as subject_name,
        trim(qualification_type)                        as qualification_type,
        trim(qualification_size)                        as qualification_size,

        -- Cohort
        safe_cast(cohort_size as int64)                 as cohort_count,

        -- Grade distribution (BTEC-style)
        {{ safe_cast_percentage('pct_distinction_star') }} as distinction_star_pct,
        {{ safe_cast_percentage('pct_distinction') }}   as distinction_pct,
        {{ safe_cast_percentage('pct_merit') }}         as merit_pct,
        {{ safe_cast_percentage('pct_pass') }}          as pass_pct,

        -- Attainment metrics
        {{ safe_cast_percentage('pass_rate') }}         as pass_rate_pct,
        {{ safe_cast_percentage('high_grade_rate') }}   as high_grade_rate_pct,
        safe_cast(avg_points as numeric)                as average_points,

        -- Value-added
        safe_cast(va_score as numeric)                  as va_score,
        trim(va_band)                                   as va_band,

        -- National comparison
        {{ safe_cast_percentage('national_pass_rate') }} as national_pass_rate_pct,
        {{ safe_cast_percentage('national_high_grade') }} as national_high_grade_pct,
        {{ safe_cast_percentage('percentile_rank') }}   as percentile_rank,

        -- Source metadata
        report_filename,
        report_type,
        dataset_index,
        report_date,
        parsed_at,

        -- Metadata
        'six_dimensions'                                as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from cleaned
