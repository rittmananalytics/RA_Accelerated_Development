{{
    config(
        materialized='table',
        tags=['dimensions', 'marts']
    )
}}

{#-
Course header dimension for programme-level analysis.
Grain: One row per course header.
-#}

with source as (

    select * from {{ ref('stg_prosolution__course_header') }}

),

final as (

    select
        -- Surrogate key
        {{ generate_int_surrogate_key(['course_header_id']) }} as course_header_key,

        -- Natural key
        course_header_id,

        -- Attributes
        course_code,
        course_name,
        subject_area,
        department,
        is_active,

        -- Metadata
        record_source,
        loaded_at

    from source

)

select * from final
