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
        student_ref,

        -- Dates
        date_of_birth,
        first_enrolment_date,

        -- Metadata
        'prosolution'                                   as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from renamed
