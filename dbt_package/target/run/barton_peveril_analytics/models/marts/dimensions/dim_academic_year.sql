
  
    

    create or replace table `ra-warehouse-dev`.`analytics`.`dim_academic_year`
      
    
    

    
    OPTIONS()
    as (
      with academic_years as (

    -- Get distinct academic years from offerings
    select distinct
        academic_year_id
    from `ra-warehouse-dev`.`analytics_staging`.`stg_prosolution__offering`
    where academic_year_id is not null

),

enriched as (

    select
        -- Surrogate key
        farm_fingerprint(
        concat(
            
                coalesce(cast(academic_year_id as string), '_dbt_null_')
                
            
        )
    )
 as academic_year_key,

        -- Natural key
        academic_year_id,

        -- Attributes
        concat('20', substr(academic_year_id, 1, 2), '/', '20', substr(academic_year_id, 4, 2)) as academic_year_name,

        -- Date parsing (assuming academic year starts Sept 1)
        parse_date('%Y-%m-%d', concat('20', substr(academic_year_id, 1, 2), '-09-01')) as academic_year_start_date,
        parse_date('%Y-%m-%d', concat('20', substr(academic_year_id, 4, 2), '-08-31')) as academic_year_end_date,

        -- Calendar years
        cast(concat('20', substr(academic_year_id, 1, 2)) as int64) as calendar_year_start,
        cast(concat('20', substr(academic_year_id, 4, 2)) as int64) as calendar_year_end,

        -- Current year flag
        case
            when academic_year_id = '24/25' then true
            else false
        end as is_current_year,

        -- Years from current (for trending)
        array_length(
            array(
                select ay from unnest(['19/20', '20/21', '21/22', '22/23', '23/24', '24/25']) as ay
                where ay >= academic_year_id and ay <= '24/25'
            )
        ) - 1 as years_from_current,

        -- Metadata
        'prosolution' as record_source,
        current_timestamp() as loaded_at

    from academic_years

)

select * from enriched
order by academic_year_id desc
    );
  