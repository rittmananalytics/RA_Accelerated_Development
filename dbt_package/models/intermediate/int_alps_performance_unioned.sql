{{
    config(
        materialized='view',
        tags=['intermediate', 'external_benchmark']
    )
}}

{#-
Unions A-Level and BTEC ALPS performance data into a single model
with standardized column names.
-#}

with a_level as (

    select
        academic_year_id,
        alps_subject_name,
        'A-Level'                                       as qualification_type,
        null                                            as qualification_size,
        cohort_count,

        -- A-Level specific grade counts
        grade_a_star_count,
        grade_a_count,
        grade_b_count,
        grade_c_count,
        grade_d_count,
        grade_e_count,
        grade_u_count,

        -- A-Level specific grade percentages
        grade_a_star_pct,
        grade_a_pct,
        grade_b_pct,
        grade_c_pct,
        grade_d_pct,
        grade_e_pct,
        grade_u_pct,

        -- BTEC columns as NULL for A-Level
        cast(null as int64)                             as btec_distinction_star_count,
        cast(null as int64)                             as btec_distinction_count,
        cast(null as int64)                             as btec_merit_count,
        cast(null as int64)                             as btec_pass_count,
        cast(null as numeric)                           as btec_distinction_star_pct,
        cast(null as numeric)                           as btec_distinction_pct,
        cast(null as numeric)                           as btec_merit_pct,
        cast(null as numeric)                           as btec_pass_pct,

        -- Cumulative percentages
        coalesce(grade_a_star_pct, 0) + coalesce(grade_a_pct, 0) as a_star_to_a_pct,
        coalesce(grade_a_star_pct, 0) + coalesce(grade_a_pct, 0) + coalesce(grade_b_pct, 0) as a_star_to_b_pct,
        coalesce(grade_a_star_pct, 0) + coalesce(grade_a_pct, 0) + coalesce(grade_b_pct, 0) + coalesce(grade_c_pct, 0) as a_star_to_c_pct,
        coalesce(grade_a_star_pct, 0) + coalesce(grade_a_pct, 0) + coalesce(grade_b_pct, 0) + coalesce(grade_c_pct, 0) + coalesce(grade_d_pct, 0) + coalesce(grade_e_pct, 0) as a_star_to_e_pct,

        -- High grade (A*-B)
        coalesce(grade_a_star_pct, 0) + coalesce(grade_a_pct, 0) + coalesce(grade_b_pct, 0) as high_grade_pct,

        -- Pass rate (A*-E)
        coalesce(grade_a_star_pct, 0) + coalesce(grade_a_pct, 0) + coalesce(grade_b_pct, 0) + coalesce(grade_c_pct, 0) + coalesce(grade_d_pct, 0) + coalesce(grade_e_pct, 0) as pass_rate_pct,

        -- ALPS metrics
        alps_band,
        alps_score,
        t_score,
        average_grade_points,

        -- Source metadata
        report_filename,
        report_date,
        record_source,
        loaded_at

    from {{ ref('stg_alps__a_level_performance') }}

),

btec as (

    select
        academic_year_id,
        alps_subject_name,
        'BTEC'                                          as qualification_type,
        qualification_size,
        cohort_count,

        -- A-Level columns as NULL for BTEC
        cast(null as int64)                             as grade_a_star_count,
        cast(null as int64)                             as grade_a_count,
        cast(null as int64)                             as grade_b_count,
        cast(null as int64)                             as grade_c_count,
        cast(null as int64)                             as grade_d_count,
        cast(null as int64)                             as grade_e_count,
        cast(null as int64)                             as grade_u_count,
        cast(null as numeric)                           as grade_a_star_pct,
        cast(null as numeric)                           as grade_a_pct,
        cast(null as numeric)                           as grade_b_pct,
        cast(null as numeric)                           as grade_c_pct,
        cast(null as numeric)                           as grade_d_pct,
        cast(null as numeric)                           as grade_e_pct,
        cast(null as numeric)                           as grade_u_pct,

        -- BTEC specific grade counts
        btec_distinction_star_count,
        btec_distinction_count,
        btec_merit_count,
        btec_pass_count,

        -- BTEC specific grade percentages
        btec_distinction_star_pct,
        btec_distinction_pct,
        btec_merit_pct,
        btec_pass_pct,

        -- Cumulative percentages (not applicable for BTEC)
        cast(null as numeric)                           as a_star_to_a_pct,
        cast(null as numeric)                           as a_star_to_b_pct,
        cast(null as numeric)                           as a_star_to_c_pct,
        cast(null as numeric)                           as a_star_to_e_pct,

        -- High grade (D*-M)
        coalesce(btec_distinction_star_pct, 0) + coalesce(btec_distinction_pct, 0) + coalesce(btec_merit_pct, 0) as high_grade_pct,

        -- Pass rate (D*-P)
        coalesce(btec_distinction_star_pct, 0) + coalesce(btec_distinction_pct, 0) + coalesce(btec_merit_pct, 0) + coalesce(btec_pass_pct, 0) as pass_rate_pct,

        -- ALPS metrics
        alps_band,
        alps_score,
        cast(null as numeric)                           as t_score,
        cast(null as numeric)                           as average_grade_points,

        -- Source metadata
        report_filename,
        report_date,
        record_source,
        loaded_at

    from {{ ref('stg_alps__btec_performance') }}

),

unioned as (

    select * from a_level
    union all
    select * from btec

)

select * from unioned
