{{
    config(
        materialized='table',
        tags=['dimensions', 'marts']
    )
}}

{#-
Student demographic details dimension for equity and diversity analysis.
Grain: One row per student per academic year.
-#}

with source as (

    select * from {{ ref('int_student_demographics_joined') }}

),

final as (

    select
        -- Surrogate key
        {{ generate_int_surrogate_key(['student_detail_id']) }} as student_detail_key,

        -- Natural keys
        student_detail_id,
        student_id,
        academic_year_id,

        -- Core demographics
        full_name,
        gender,
        ethnicity,

        -- Demographic flags for equity analysis
        is_free_meals,
        is_bursary,
        is_lac,
        is_send,
        is_high_needs,
        is_young_carer,

        -- SEND details
        primary_send_type,
        secondary_send_type,

        -- Geographic
        postcode_area,
        imd_decile,
        polar4_quintile,
        tundra_classification,

        -- Background
        nationality,
        country_of_birth,
        first_language,
        religion,

        -- Prior attainment
        average_gcse_score,
        prior_attainment_band,

        -- Metadata
        record_source,
        loaded_at

    from source

)

select * from final
