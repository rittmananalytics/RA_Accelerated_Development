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

        -- Demographic flags for equity analysis (JEDI)
        is_disadvantaged,
        is_pupil_premium,
        is_free_school_meals,
        is_sen,
        is_access_plus,
        has_additional_adjustments,
        is_bursary_recipient,

        -- Ethnicity
        ethnicity_code,
        ethnicity_description,
        ethnicity_group,

        -- SEND
        sen_type as send_category,
        cast(null as string) as send_type,

        -- Geographic
        postcode_area,
        cast(null as int64) as imd_decile,  -- Would need to be enriched from external data

        -- Metadata
        record_source,
        loaded_at

    from source

)

select * from final
