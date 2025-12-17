

with source as (

    select * from `ra-warehouse-dev`.`analytics_seed_raw_prosolution`.`completion_status`

),

renamed as (

    select
        -- Primary key
        completion_status_id,

        -- Attributes
        name                                            as status_name,
        description                                     as status_description,

        -- Derived flags based on typical MIS status codes
        case
            when completion_status_id = 1 then true     -- Completed
            else false
        end                                             as is_completed,

        case
            when completion_status_id = 2 then true     -- Continuing
            else false
        end                                             as is_continuing,

        case
            when completion_status_id in (3, 4) then true  -- Withdrawn
            else false
        end                                             as is_withdrawn,

        -- Metadata
        'prosolution'                                   as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from renamed