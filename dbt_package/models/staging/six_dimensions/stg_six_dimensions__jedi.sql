{{
    config(
        materialized='view',
        tags=['staging', 'six_dimensions', 'external_benchmark']
    )
}}

with source as (

    select * from {{ source('raw_six_dimensions', 'jedi_report') }}

),

cleaned as (

    select
        -- Keys
        report_year                                     as academic_year_id,
        trim(demographic_category)                      as demographic_category,
        trim(demographic_value)                         as demographic_value,

        -- Cohort metrics
        safe_cast(cohort_size as int64)                 as cohort_count,
        {{ safe_cast_percentage('pct_of_total') }}      as cohort_pct,

        -- Attainment metrics
        {{ safe_cast_percentage('pass_rate') }}         as pass_rate_pct,
        {{ safe_cast_percentage('high_grade_rate') }}   as high_grade_rate_pct,
        safe_cast(avg_points as numeric)                as average_points,

        -- Value-added
        safe_cast(va_score as numeric)                  as va_score,
        trim(va_band)                                   as va_band,

        -- Gap metrics
        {{ safe_cast_percentage('gap_vs_overall') }}    as gap_vs_overall_pct,
        {{ safe_cast_percentage('gap_vs_national') }}   as gap_vs_national_pct,

        -- National benchmarks
        {{ safe_cast_percentage('national_pass_rate') }} as national_pass_rate_pct,
        {{ safe_cast_percentage('national_high_grade') }} as national_high_grade_pct,

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
