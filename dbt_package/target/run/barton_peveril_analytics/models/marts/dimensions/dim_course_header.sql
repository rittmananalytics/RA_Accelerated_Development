
  
    

    create or replace table `ra-warehouse-dev`.`analytics`.`dim_course_header`
      
    
    

    
    OPTIONS()
    as (
      with source as (

    select * from `ra-warehouse-dev`.`analytics_staging`.`stg_prosolution__course_header`

),

final as (

    select
        -- Surrogate key
        farm_fingerprint(
        concat(
            
                coalesce(cast(course_header_id as string), '_dbt_null_')
                
            
        )
    )
 as course_header_key,

        -- Natural key
        course_header_id,

        -- Attributes
        course_code,
        course_name,
        subject_area,
        department,
        is_active,

        -- Metadata
        record_source,
        loaded_at

    from source

)

select * from final
    );
  