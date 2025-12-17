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
        jedi_report_id,
        academic_year                                   as academic_year_id,
        trim(report_type)                               as report_type,
        trim(dimension_name)                            as dimension_name,

        -- Groups
        trim(student_group)                             as student_group,
        trim(comparison_group)                          as comparison_group,

        -- Cohort metrics
        safe_cast(student_count as int64)               as student_count,
        safe_cast(comparison_count as int64)            as comparison_count,

        -- Grade point metrics
        safe_cast(student_avg_grade_points as numeric)  as student_avg_grade_points,
        safe_cast(comparison_avg_grade_points as numeric) as comparison_avg_grade_points,
        safe_cast(gap_grade_points as numeric)          as gap_grade_points,

        -- Significance and performance
        gap_significance,
        performance_band,

        -- Source metadata
        report_date,

        -- Metadata
        'six_dimensions'                                as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from cleaned
