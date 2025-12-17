{{
    config(
        materialized='view',
        tags=['staging', 'alps', 'external_benchmark']
    )
}}

with source as (

    select * from {{ source('raw_alps', 'provider_report_a_level') }}

),

cleaned as (

    select
        -- Keys
        report_year                                     as academic_year_id,
        trim(subject_name)                              as alps_subject_name,

        -- Cohort
        cast(cohort_size as int64)                      as cohort_count,

        -- Grade distribution counts
        cast(grade_a_star as int64)                     as grade_a_star_count,
        cast(grade_a as int64)                          as grade_a_count,
        cast(grade_b as int64)                          as grade_b_count,
        cast(grade_c as int64)                          as grade_c_count,
        cast(grade_d as int64)                          as grade_d_count,
        cast(grade_e as int64)                          as grade_e_count,
        cast(grade_u as int64)                          as grade_u_count,

        -- Grade percentages (parse from string, removing % if present)
        {{ safe_cast_percentage('pct_a_star') }}        as grade_a_star_pct,
        {{ safe_cast_percentage('pct_a') }}             as grade_a_pct,
        {{ safe_cast_percentage('pct_b') }}             as grade_b_pct,
        {{ safe_cast_percentage('pct_c') }}             as grade_c_pct,
        {{ safe_cast_percentage('pct_d') }}             as grade_d_pct,
        {{ safe_cast_percentage('pct_e') }}             as grade_e_pct,
        {{ safe_cast_percentage('pct_u') }}             as grade_u_pct,

        -- ALPS metrics
        safe_cast(regexp_replace(alps_grade, '[^0-9]', '') as int64) as alps_band,
        safe_cast(alps_score as numeric)                as alps_score,
        safe_cast(t_score as numeric)                   as t_score,

        -- Averages
        safe_cast(avg_points as numeric)                as average_grade_points,

        -- Source metadata
        report_filename,
        report_date,
        parsed_at,

        -- Metadata
        'alps'                                          as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from cleaned
