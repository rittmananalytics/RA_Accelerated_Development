{{
    config(
        materialized='table',
        tags=['dimensions', 'marts']
    )
}}

{#-
Offering type dimension for qualification categorization.
Grain: One row per offering type.
-#}

with source as (

    select * from {{ ref('stg_prosolution__offering_type') }}

),

final as (

    select
        -- Surrogate key
        {{ generate_int_surrogate_key(['offering_type_id']) }} as offering_type_key,

        -- Natural key
        offering_type_id,

        -- Attributes
        offering_type_name,
        offering_type_category,
        qualification_level,
        grading_scale,
        is_academic,
        is_vocational,

        -- Metadata
        record_source,
        loaded_at

    from source

)

select * from final
