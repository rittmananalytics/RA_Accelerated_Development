with source as (

    select * from `ra-warehouse-dev`.`analytics_staging`.`stg_prosolution__offering_type`

),

final as (

    select
        -- Surrogate key
        farm_fingerprint(
        concat(
            
                coalesce(cast(offering_type_id as string), '_dbt_null_')
                
            
        )
    )
 as offering_type_key,

        -- Natural key
        offering_type_id,

        -- Attributes
        offering_type_name,
        offering_type_category,
        qualification_level,
        grading_scale,
        is_academic,
        is_vocational,

        -- Metadata
        record_source,
        loaded_at

    from source

)

select * from final