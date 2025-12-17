with va_subject as (

    select
        va_report_id                                    as report_id,
        academic_year_id,
        'VA'                                            as report_type,
        subject_name                                    as six_dimensions_subject_name,
        qualification_type,
        cohort_count,
        average_gcse_on_entry,
        value_added_score,
        residual_score,
        expected_grade,
        actual_avg_grade,
        performance_band,
        confidence_interval_lower,
        confidence_interval_upper,
        cast(null as numeric)                           as pass_rate_pct,
        cast(null as numeric)                           as high_grades_pct,
        cast(null as numeric)                           as completion_rate_pct,
        cast(null as numeric)                           as achievement_rate_pct,
        cast(null as string)                            as performance_quartile,
        report_date,
        record_source,
        loaded_at

    from `ra-warehouse-dev`.`analytics_staging`.`stg_six_dimensions__va`
    where subject_name is not null

),

sixth_sense_subject as (

    select
        sixth_sense_id                                  as report_id,
        academic_year_id,
        'Sixth Sense'                                   as report_type,
        subject_name                                    as six_dimensions_subject_name,
        qualification_type,
        cohort_count,
        cast(null as numeric)                           as average_gcse_on_entry,
        cast(null as numeric)                           as value_added_score,
        cast(null as numeric)                           as residual_score,
        cast(null as string)                            as expected_grade,
        cast(null as string)                            as actual_avg_grade,
        cast(null as string)                            as performance_band,
        cast(null as numeric)                           as confidence_interval_lower,
        cast(null as numeric)                           as confidence_interval_upper,
        pass_rate_pct,
        high_grades_pct,
        completion_rate_pct,
        achievement_rate_pct,
        performance_quartile,
        report_date,
        record_source,
        loaded_at

    from `ra-warehouse-dev`.`analytics_staging`.`stg_six_dimensions__sixth_sense`
    where subject_name is not null

),

vocational_subject as (

    select
        vocational_report_id                            as report_id,
        academic_year_id,
        'Vocational'                                    as report_type,
        subject_name                                    as six_dimensions_subject_name,
        qualification_type,
        cohort_count,
        average_gcse_on_entry,
        cast(null as numeric)                           as value_added_score,
        cast(null as numeric)                           as residual_score,
        cast(null as string)                            as expected_grade,
        cast(null as string)                            as actual_avg_grade,
        performance_band,
        cast(null as numeric)                           as confidence_interval_lower,
        cast(null as numeric)                           as confidence_interval_upper,
        pass_rate_pct,
        cast(null as numeric)                           as high_grades_pct,
        completion_rate_pct,
        achievement_rate_pct,
        cast(null as string)                            as performance_quartile,
        report_date,
        record_source,
        loaded_at

    from `ra-warehouse-dev`.`analytics_staging`.`stg_six_dimensions__vocational`
    where subject_name is not null

),

unioned as (

    select * from va_subject
    union all
    select * from sixth_sense_subject
    union all
    select * from vocational_subject

)

select * from unioned