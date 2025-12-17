{{
    config(
        materialized='view',
        tags=['staging', 'prosolution']
    )
}}

with source as (

    select * from {{ source('raw_prosolution', 'offering') }}

),

renamed as (

    select
        -- Primary key
        offering_id,

        -- Foreign keys
        course_header_id,
        offering_type_id,
        academic_year_id,

        -- Attributes
        code                                            as offering_code,
        name                                            as offering_name,
        qual_id                                         as qualification_id,
        study_year,
        duration                                        as duration_years,

        -- Derived: is this the final year of the programme?
        case
            when study_year = duration then true
            else false
        end                                             as is_final_year,

        -- Dates
        start_date,
        end_date,

        -- Flags
        coalesce(is_active, true)                       as is_active,

        -- Derived: filter out non-qualification offerings
        case
            when qual_id is null then false
            when lower(qual_id) like 'enrich%' then false
            when lower(qual_id) like 'zwr%' then false
            when lower(qual_id) like '%tutor%' then false
            else true
        end                                             as is_valid_qualification,

        -- Metadata
        'prosolution'                                   as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from renamed
