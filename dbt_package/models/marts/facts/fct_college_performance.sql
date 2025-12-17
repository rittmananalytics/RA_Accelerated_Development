{{
    config(
        materialized='table',
        tags=['facts', 'marts', 'external_benchmark'],
        cluster_by=['academic_year_key', 'report_type']
    )
}}

{#-
College-level performance metrics from Six Dimensions.
Grain: One row per report type per academic year.
-#}

with college_performance as (

    select * from {{ ref('int_six_dimensions_college_unioned') }}

),

dim_academic_year as (

    select * from {{ ref('dim_academic_year') }}

),

final as (

    select
        -- Surrogate key
        {{ generate_int_surrogate_key(['cp.academic_year_id', 'cp.report_type']) }} as college_performance_key,

        -- Dimension foreign key
        ay.academic_year_key,

        -- Source identifiers
        cp.report_type,
        cp.report_name,

        -- Cohort measures
        cp.total_cohort_count,
        cast(null as int64) as a_level_cohort_count,
        cast(null as int64) as btec_cohort_count,
        cast(null as int64) as vocational_cohort_count,

        -- Attainment metrics
        cp.pass_rate_pct,
        cp.high_grade_rate_pct,
        cp.average_grade_points,
        cp.average_ucas_points,

        -- Value-added metrics
        cp.va_score,
        cp.va_band,
        cp.va_confidence_lower,
        cp.va_confidence_upper,
        cp.va_percentile,
        cp.va_national_rank,

        -- Sixth Sense metrics
        cp.sixth_sense_score,
        cp.sixth_sense_band,

        -- National benchmarks
        cast(null as numeric) as national_pass_rate_pct,
        cast(null as numeric) as national_high_grade_pct,
        cp.national_percentile_rank,

        -- Variance from benchmark
        cast(null as numeric) as pass_rate_vs_national_pct,
        cast(null as numeric) as high_grade_vs_national_pct,

        -- Metadata
        cp.report_date,
        cp.record_source,
        cp.loaded_at

    from college_performance cp
    inner join dim_academic_year ay
        on cp.academic_year_id = ay.academic_year_id

)

select * from final
