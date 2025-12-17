

with source as (

    select * from `ra-warehouse-dev`.`analytics_seed_raw_prosolution`.`course_header`

),

renamed as (

    select
        -- Primary key
        course_header_id,

        -- Attributes
        code                                            as course_code,
        name                                            as course_name,
        description                                     as course_description,

        -- Classification
        subject_area,
        department,
        faculty,

        -- Flags
        coalesce(is_active, true)                       as is_active,

        -- Metadata
        'prosolution'                                   as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from renamed