
  
    

    create or replace table `ra-warehouse-dev`.`analytics`.`fct_college_performance`
      
    
    cluster by academic_year_key, report_type

    
    OPTIONS()
    as (
      with college_performance as (

    select * from `ra-warehouse-dev`.`analytics_integration`.`int_six_dimensions_college_unioned`

),

dim_academic_year as (

    select * from `ra-warehouse-dev`.`analytics`.`dim_academic_year`

),

final as (

    select
        -- Surrogate key
        farm_fingerprint(
        concat(
            
                coalesce(cast(cp.academic_year_id as string), '_dbt_null_')
                , '|', 
            
                coalesce(cast(cp.report_type as string), '_dbt_null_')
                
            
        )
    )
 as college_performance_key,

        -- Dimension foreign key
        ay.academic_year_key,

        -- Source identifiers
        cp.report_type,
        cp.report_name,

        -- Cohort measures
        cp.total_cohort_count,

        -- Performance metrics (from Sixth Sense)
        cp.avg_pass_rate_pct,
        cp.avg_high_grades_pct,
        cp.avg_completion_rate_pct,
        cp.avg_retention_rate_pct,
        cp.avg_achievement_rate_pct,
        cp.avg_attendance_rate_pct,

        -- Value-added metrics (from VA reports)
        cp.avg_value_added_score,
        cp.avg_confidence_lower,
        cp.avg_confidence_upper,

        -- Metadata
        cp.report_date,
        cp.record_source,
        cp.loaded_at

    from college_performance cp
    inner join dim_academic_year ay
        on cp.academic_year_id = ay.academic_year_id

)

select * from final
    );
  