
  
    

    create or replace table `ra-warehouse-dev`.`analytics`.`dim_grade`
      
    
    

    
    OPTIONS()
    as (
      with grade_points as (

    select * from `ra-warehouse-dev`.`analytics_seed`.`seed_grade_points`

),

final as (

    select
        -- Surrogate key
        farm_fingerprint(
        concat(
            
                coalesce(cast(grade as string), '_dbt_null_')
                , '|', 
            
                coalesce(cast(qualification_type as string), '_dbt_null_')
                
            
        )
    )
 as grade_key,

        -- Natural key
        grade,
        qualification_type as grading_scale,

        -- Point values
        ucas_points,
        grade_points,
        grade_sort_order,

        -- Grade classification flags
        is_high_grade,
        is_pass as is_pass_grade,

        -- Cumulative grade flags (A-Level specific)
        case when grade in ('A*', 'A') then true else false end as is_grade_a_star_to_a,
        case when grade in ('A*', 'A', 'B') then true else false end as is_grade_a_star_to_b,
        case when grade in ('A*', 'A', 'B', 'C') then true else false end as is_grade_a_star_to_c,
        case when grade in ('A*', 'A', 'B', 'C', 'D', 'E') then true else false end as is_grade_a_star_to_e,

        -- Metadata
        'seed' as record_source,
        current_timestamp() as loaded_at

    from grade_points

)

select * from final
    );
  