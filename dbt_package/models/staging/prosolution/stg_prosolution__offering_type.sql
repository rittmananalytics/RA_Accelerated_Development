{{
    config(
        materialized='view',
        tags=['staging', 'prosolution']
    )
}}

with source as (

    select * from {{ source('raw_prosolution', 'offering_type') }}

),

renamed as (

    select
        -- Primary key
        offering_type_id,

        -- Attributes
        name                                            as offering_type_name,
        description                                     as offering_type_description,
        category                                        as offering_type_category,
        qualification_level,

        -- Derived grading scale
        case
            when offering_type_id in (1, 2) then 'A*-E'       -- A-Level
            when offering_type_id in (4, 8, 9) then 'D*-P'    -- BTEC
            else 'Other'
        end                                             as grading_scale,

        -- Classification flags
        case
            when offering_type_id in (1, 2) then true
            else false
        end                                             as is_academic,

        case
            when offering_type_id in (4, 8, 9) then true
            else false
        end                                             as is_vocational,

        -- Metadata
        'prosolution'                                   as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from renamed
