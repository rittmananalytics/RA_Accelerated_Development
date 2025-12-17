{{
    config(
        materialized='view',
        tags=['staging', 'prosolution']
    )
}}

with source as (

    select * from {{ source('raw_prosolution', 'student_detail') }}

),

renamed as (

    select
        -- Primary key
        student_detail_id,

        -- Foreign keys
        student_id,
        academic_year_id,

        -- Location
        postcode,
        -- Extract postcode area (first part)
        split(postcode, ' ')[safe_offset(0)]           as postcode_area,

        -- SEND information
        lldd_code,
        coalesce(is_send, false)                        as is_send,
        coalesce(is_high_needs, false)                  as is_high_needs,
        primary_send_type,
        secondary_send_type,

        -- Disadvantage flags
        coalesce(is_free_meals, false)                  as is_free_meals,
        coalesce(is_bursary, false)                     as is_bursary,
        coalesce(is_lac, false)                         as is_lac,

        -- Metadata
        'prosolution'                                   as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from renamed
