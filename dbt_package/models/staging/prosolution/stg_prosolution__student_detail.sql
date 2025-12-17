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

        -- Gender (normalized)
        upper(trim(sex))                                as gender_code,
        case upper(trim(sex))
            when 'M' then 'Male'
            when 'F' then 'Female'
            else 'Other'
        end                                             as gender,

        -- Date of birth
        date_of_birth,

        -- Ethnicity
        ethnicity_code,
        ethnicity_description,
        -- Grouped ethnicity for analysis
        case
            when ethnicity_code in ('WBRI', 'WIRI', 'WOTH', 'WROM') then 'White'
            when ethnicity_code in ('MWBC', 'MWBA', 'MWAS', 'MOTH') then 'Mixed'
            when ethnicity_code in ('AIND', 'APKN', 'ABAN', 'AOTH') then 'Asian'
            when ethnicity_code in ('BCRB', 'BAFR', 'BOTH') then 'Black'
            when ethnicity_code in ('CHNE', 'OOTH') then 'Other'
            when ethnicity_code = 'REFU' then 'Prefer not to say'
            else 'Unknown'
        end                                             as ethnicity_group,

        -- Location
        postcode,
        -- Extract postcode area (first part)
        split(postcode, ' ')[safe_offset(0)]           as postcode_area,

        -- Flags
        coalesce(is_current, true)                      as is_current,

        -- Metadata
        'prosolution'                                   as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from renamed
