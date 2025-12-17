with alps_performance as (

    select * from `ra-warehouse-dev`.`analytics_integration`.`int_alps_performance_unioned`

),

dim_academic_year as (

    select * from `ra-warehouse-dev`.`analytics`.`dim_academic_year`

),

dim_offering as (

    select * from `ra-warehouse-dev`.`analytics`.`dim_offering`

),

-- Attempt to match ALPS subjects to internal offerings
subject_mapping as (

    select
        ap.academic_year_id,
        ap.alps_subject_name,
        ap.qualification_type,
        o.offering_key,
        o.offering_id,
        -- Simple mapping status based on whether match found
        case
            when o.offering_key is not null then 'Matched'
            else 'Unmapped'
        end as subject_mapping_status,
        case
            when o.offering_key is not null then 100.0
            else 0.0
        end as mapping_confidence_pct

    from alps_performance ap
    left join dim_offering o
        on ap.alps_subject_name = o.alps_subject_name
        and ap.academic_year_id = o.academic_year_id

),

final as (

    select
        -- Surrogate key
        farm_fingerprint(
        concat(
            
                coalesce(cast(ap.academic_year_id as string), '_dbt_null_')
                , '|', 
            
                coalesce(cast(ap.alps_subject_name as string), '_dbt_null_')
                , '|', 
            
                coalesce(cast(ap.qualification_type as string), '_dbt_null_')
                
            
        )
    )
 as alps_subject_performance_key,

        -- Dimension foreign keys
        ay.academic_year_key,
        sm.offering_key,

        -- ALPS identifiers
        ap.alps_subject_name,
        ap.qualification_type as alps_qualification_type,

        -- Subject mapping
        sm.subject_mapping_status,
        sm.mapping_confidence_pct,

        -- Cohort
        ap.cohort_count,
        ap.average_gcse_on_entry,

        -- ALPS benchmarking metrics
        ap.alps_band,
        ap.alps_score,
        ap.value_added_score,
        ap.national_benchmark_grade,

        -- Performance percentages
        ap.pass_rate_pct,
        ap.high_grades_pct,

        -- Metadata
        ap.report_date as alps_report_date,
        ap.record_source,
        ap.loaded_at

    from alps_performance ap
    inner join dim_academic_year ay
        on ap.academic_year_id = ay.academic_year_id
    left join subject_mapping sm
        on ap.academic_year_id = sm.academic_year_id
        and ap.alps_subject_name = sm.alps_subject_name
        and ap.qualification_type = sm.qualification_type

)

select * from final