{{
    config(
        materialized='view',
        tags=['staging', 'six_dimensions', 'external_benchmark']
    )
}}

with source as (

    select * from {{ source('raw_six_dimensions', 'va_report') }}

),

cleaned as (

    select
        -- Keys
        report_year                                     as academic_year_id,
        trim(level)                                     as level,
        trim(subject_name)                              as subject_name,

        -- Cohort
        safe_cast(cohort_size as int64)                 as cohort_count,

        -- Attainment metrics
        {{ safe_cast_percentage('pass_rate') }}         as pass_rate_pct,
        {{ safe_cast_percentage('high_grade_rate') }}   as high_grade_rate_pct,
        safe_cast(avg_points as numeric)                as average_points,

        -- Value-added metrics
        safe_cast(va_score as numeric)                  as va_score,
        safe_cast(va_residual as numeric)               as va_residual,
        trim(va_band)                                   as va_band,
        {{ safe_cast_percentage('va_percentile') }}     as va_percentile,
        safe_cast(va_confidence_lower as numeric)       as va_confidence_lower,
        safe_cast(va_confidence_upper as numeric)       as va_confidence_upper,

        -- National comparison
        {{ safe_cast_percentage('national_percentile') }} as national_percentile,
        safe_cast(national_rank as int64)               as national_rank,

        -- Source metadata
        report_filename,
        report_type,
        report_date,
        parsed_at,

        -- Metadata
        'six_dimensions'                                as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from cleaned
