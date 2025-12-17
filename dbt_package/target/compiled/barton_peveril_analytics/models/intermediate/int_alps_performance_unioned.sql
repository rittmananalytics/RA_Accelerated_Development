with a_level as (

    select
        alps_report_id                                  as report_id,
        academic_year_id,
        alps_subject_name,
        'A-Level'                                       as qualification_type,
        cast(null as string)                            as qualification_size,
        cohort_count,
        average_gcse_on_entry,

        -- ALPS metrics
        alps_band,
        alps_score,
        value_added_score,
        national_benchmark_grade,

        -- Performance percentages
        pass_rate_pct,
        high_grades_pct,

        -- Source metadata
        report_date,
        record_source,
        loaded_at

    from `ra-warehouse-dev`.`analytics_staging`.`stg_alps__a_level_performance`

),

btec as (

    select
        alps_btec_report_id                             as report_id,
        academic_year_id,
        alps_subject_name,
        qualification_type,
        cast(null as string)                            as qualification_size,
        cohort_count,
        average_gcse_on_entry,

        -- ALPS metrics
        alps_band,
        alps_score,
        value_added_score,
        national_benchmark_grade,

        -- Performance percentages
        pass_rate_pct,
        high_grades_pct,

        -- Source metadata
        report_date,
        record_source,
        loaded_at

    from `ra-warehouse-dev`.`analytics_staging`.`stg_alps__btec_performance`

),

unioned as (

    select * from a_level
    union all
    select * from btec

)

select * from unioned