

with source as (

    select * from `ra-warehouse-dev`.`analytics_seed_raw_six_dimensions`.`va_report`

),

cleaned as (

    select
        -- Keys
        va_report_id,
        academic_year                                   as academic_year_id,
        trim(subject_name)                              as subject_name,
        trim(qualification_type)                        as qualification_type,

        -- Cohort
        safe_cast(student_count as int64)               as cohort_count,
        safe_cast(average_gcse_on_entry as numeric)     as average_gcse_on_entry,

        -- Value-added metrics
        safe_cast(value_added_score as numeric)         as value_added_score,
        safe_cast(residual_score as numeric)            as residual_score,
        expected_grade,
        actual_avg_grade,
        performance_band,

        -- Confidence intervals
        safe_cast(confidence_interval_lower as numeric) as confidence_interval_lower,
        safe_cast(confidence_interval_upper as numeric) as confidence_interval_upper,

        -- Source metadata
        report_date,

        -- Metadata
        'six_dimensions'                                as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from cleaned