{{
    config(
        materialized='view',
        tags=['staging', 'prosolution']
    )
}}

with source as (

    select * from {{ source('raw_prosolution', 'student') }}

),

renamed as (

    select
        -- Primary key
        student_id,

        -- Identifiers
        uln,

        -- Personal information
        first_name,
        last_name,
        concat(first_name, ' ', last_name)              as full_name,
        email,

        -- Demographics
        date_of_birth,
        gender,
        ethnicity,

        -- Status
        coalesce(is_active, true)                       as is_active,

        -- Dates
        created_at,
        updated_at,

        -- Metadata
        'prosolution'                                   as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from renamed
