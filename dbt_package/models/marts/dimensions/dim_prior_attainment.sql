{{
    config(
        materialized='table',
        tags=['dimensions', 'marts']
    )
}}

{#-
Prior attainment dimension for ALPS-style value-added analysis.
Grain: One row per student.
-#}

with source as (

    select * from {{ ref('stg_focus__average_gcse') }}

),

final as (

    select
        -- Surrogate key
        {{ generate_int_surrogate_key(['student_id']) }} as prior_attainment_key,

        -- Natural key
        student_id,

        -- GCSE metrics
        average_gcse_score,
        prior_attainment_band,
        prior_attainment_band_code,

        -- Thresholds (from project variables)
        cast({{ var('prior_attainment_low_threshold') }} as numeric) as low_threshold,
        cast({{ var('prior_attainment_high_threshold') }} as numeric) as high_threshold,

        -- Individual subject grades
        gcse_english_grade,
        gcse_maths_grade,
        total_gcse_points,
        gcse_count,

        -- Metadata
        record_source,
        loaded_at

    from source

)

select * from final
