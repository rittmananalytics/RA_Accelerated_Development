

with source as (

    select * from `ra-warehouse-dev`.`analytics_seed_raw_mis_applications`.`student_extended_data`

),

renamed as (

    select
        -- Primary key
        student_extended_id,

        -- Foreign key
        student_id,
        academic_year_id,

        -- Background information
        nationality,
        country_of_birth,
        first_language,
        religion,

        -- Care and support flags
        coalesce(is_young_carer, false)                 as is_young_carer,
        coalesce(is_parent_carer, false)                as is_parent_carer,
        care_leaver_status,
        asylum_seeker_status,
        armed_forces_status,
        household_situation,

        -- Deprivation indices
        cast(imd_decile as int64)                       as imd_decile,
        cast(polar4_quintile as int64)                  as polar4_quintile,
        tundra_classification,

        -- Metadata
        'mis_applications'                              as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from renamed