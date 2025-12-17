{{
    config(
        materialized='view',
        tags=['staging', 'alps', 'external_benchmark']
    )
}}

with source as (

    select * from {{ source('raw_alps', 'provider_report_btec') }}

),

cleaned as (

    select
        -- Keys
        report_year                                     as academic_year_id,
        trim(subject_name)                              as alps_subject_name,
        qualification_size,

        -- Cohort
        cast(cohort_size as int64)                      as cohort_count,

        -- Single Award grade counts
        cast(grade_d_star as int64)                     as btec_distinction_star_count,
        cast(grade_d as int64)                          as btec_distinction_count,
        cast(grade_m as int64)                          as btec_merit_count,
        cast(grade_p as int64)                          as btec_pass_count,

        -- Double Award grade counts
        cast(grade_d_star_d_star as int64)              as btec_d_star_d_star_count,
        cast(grade_d_star_d as int64)                   as btec_d_star_d_count,
        cast(grade_dd as int64)                         as btec_dd_count,
        cast(grade_dm as int64)                         as btec_dm_count,
        cast(grade_mm as int64)                         as btec_mm_count,
        cast(grade_mp as int64)                         as btec_mp_count,
        cast(grade_pp as int64)                         as btec_pp_count,

        -- Single Award percentages
        {{ safe_cast_percentage('pct_d_star') }}        as btec_distinction_star_pct,
        {{ safe_cast_percentage('pct_d') }}             as btec_distinction_pct,
        {{ safe_cast_percentage('pct_m') }}             as btec_merit_pct,
        {{ safe_cast_percentage('pct_p') }}             as btec_pass_pct,

        -- ALPS metrics
        safe_cast(regexp_replace(alps_grade, '[^0-9]', '') as int64) as alps_band,
        safe_cast(alps_score as numeric)                as alps_score,

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
