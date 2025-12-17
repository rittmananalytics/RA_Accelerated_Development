
  
    

    create or replace table `ra-warehouse-dev`.`analytics`.`dim_prior_attainment`
      
    
    

    
    OPTIONS()
    as (
      with source as (

    select * from `ra-warehouse-dev`.`analytics_staging`.`stg_focus__average_gcse`

),

final as (

    select
        -- Surrogate key
        farm_fingerprint(
        concat(
            
                coalesce(cast(average_gcse_id as string), '_dbt_null_')
                
            
        )
    )
 as prior_attainment_key,

        -- Natural keys
        average_gcse_id,
        student_id,
        academic_year_id,

        -- GCSE metrics
        average_gcse_score,
        prior_attainment_band,
        prior_attainment_band_code,

        -- Thresholds (from project variables)
        cast(4.77 as numeric) as low_threshold,
        cast(6.09 as numeric) as high_threshold,

        -- Individual subject grades
        gcse_english_grade,
        gcse_maths_grade,
        gcse_count,

        -- Metadata
        record_source,
        loaded_at

    from source

)

select * from final
    );
  