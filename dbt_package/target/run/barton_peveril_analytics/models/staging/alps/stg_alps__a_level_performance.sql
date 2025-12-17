

  create or replace view `ra-warehouse-dev`.`analytics_staging`.`stg_alps__a_level_performance`
  OPTIONS()
  as 

with source as (

    select * from `ra-warehouse-dev`.`analytics_seed_raw_alps`.`provider_report_a_level`

),

cleaned as (

    select
        -- Keys
        alps_report_id,
        academic_year                                   as academic_year_id,
        trim(subject_name)                              as alps_subject_name,

        -- Cohort
        cast(student_count as int64)                    as cohort_count,
        safe_cast(average_gcse_on_entry as numeric)     as average_gcse_on_entry,

        -- ALPS metrics
        cast(alps_grade as int64)                       as alps_band,
        safe_cast(alps_score as numeric)                as alps_score,
        safe_cast(value_added_score as numeric)         as value_added_score,
        national_benchmark_grade,

        -- Performance percentages
        safe_cast(pass_rate_pct as numeric)             as pass_rate_pct,
        safe_cast(high_grades_pct as numeric)           as high_grades_pct,

        -- Source metadata
        report_date,

        -- Metadata
        'alps'                                          as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from cleaned;

