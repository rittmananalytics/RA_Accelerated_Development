{{
    config(
        materialized='table',
        tags=['dimensions', 'marts']
    )
}}

{#-
Grade dimension supporting multiple grading scales.
Grain: One row per grade per grading scale.
-#}

with grade_points as (

    select * from {{ ref('seed_grade_points') }}

),

final as (

    select
        -- Surrogate key
        {{ generate_int_surrogate_key(['grade', 'qualification_type']) }} as grade_key,

        -- Natural key
        grade,
        qualification_type as grading_scale,

        -- Point values
        ucas_points,
        grade_points,
        grade_sort_order,

        -- Grade classification flags
        is_high_grade,
        is_pass as is_pass_grade,

        -- Cumulative grade flags (A-Level specific)
        case when grade in ('A*', 'A') then true else false end as is_grade_a_star_to_a,
        case when grade in ('A*', 'A', 'B') then true else false end as is_grade_a_star_to_b,
        case when grade in ('A*', 'A', 'B', 'C') then true else false end as is_grade_a_star_to_c,
        case when grade in ('A*', 'A', 'B', 'C', 'D', 'E') then true else false end as is_grade_a_star_to_e,

        -- Metadata
        'seed' as record_source,
        current_timestamp() as loaded_at

    from grade_points

)

select * from final
