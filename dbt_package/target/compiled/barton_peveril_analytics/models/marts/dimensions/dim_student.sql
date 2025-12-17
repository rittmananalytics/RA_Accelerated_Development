with source as (

    select * from `ra-warehouse-dev`.`analytics_staging`.`stg_prosolution__student`

),

final as (

    select
        -- Surrogate key
        farm_fingerprint(
        concat(
            
                coalesce(cast(student_id as string), '_dbt_null_')
                
            
        )
    )
 as student_key,

        -- Natural key
        student_id,

        -- Identifiers
        uln,

        -- Demographics
        first_name,
        last_name,
        full_name,
        date_of_birth,
        gender,
        ethnicity,

        -- Status
        is_active,

        -- Dates
        created_at as first_enrolment_date,

        -- SCD Type 2 tracking (simplified - single version per student)
        date(created_at) as valid_from_date,
        cast(null as date) as valid_to_date,
        true as is_current,

        -- Metadata
        record_source,
        loaded_at

    from source

)

select * from final