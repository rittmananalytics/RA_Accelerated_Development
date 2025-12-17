{{
    config(
        materialized='table',
        tags=['facts', 'marts', 'external_benchmark'],
        cluster_by=['academic_year_key', 'six_dimensions_subject_name']
    )
}}

{#-
Subject-level benchmarking from Six Dimensions reports.
Grain: One row per subject per academic year.
-#}

with subject_performance as (

    select * from {{ ref('int_six_dimensions_subject_unioned') }}

),

dim_academic_year as (

    select * from {{ ref('dim_academic_year') }}

),

dim_offering as (

    select * from {{ ref('dim_offering') }}

),

-- Attempt to match Six Dimensions subjects to internal offerings
subject_mapping as (

    select
        sp.academic_year_id,
        sp.six_dimensions_subject_name,
        o.offering_key,
        case
            when o.offering_key is not null then 'Matched'
            else 'Unmapped'
        end as subject_mapping_status,
        case
            when o.offering_key is not null then 100.0
            else 0.0
        end as mapping_confidence_pct

    from subject_performance sp
    left join dim_offering o
        on sp.six_dimensions_subject_name = o.six_dimensions_subject_name
        and sp.academic_year_id = o.academic_year_id

),

-- Calculate year-over-year change for trajectory
with_trajectory as (

    select
        sp.*,
        lag(sp.pass_rate_pct) over (
            partition by sp.six_dimensions_subject_name
            order by sp.academic_year_id
        ) as prior_year_pass_rate,
        sp.pass_rate_pct - lag(sp.pass_rate_pct) over (
            partition by sp.six_dimensions_subject_name
            order by sp.academic_year_id
        ) as yoy_change_pct

    from subject_performance sp

),

final as (

    select
        -- Surrogate key
        {{ generate_int_surrogate_key(['wt.academic_year_id', 'wt.six_dimensions_subject_name', 'wt.report_type']) }} as subject_benchmark_key,

        -- Dimension foreign keys
        ay.academic_year_key,
        sm.offering_key,

        -- Source identifiers
        wt.report_type,
        wt.six_dimensions_subject_name,
        wt.qualification_type,

        -- Subject mapping
        sm.subject_mapping_status,
        sm.mapping_confidence_pct,

        -- Cohort
        wt.cohort_count,

        -- Attainment metrics
        wt.pass_rate_pct,
        wt.high_grade_rate_pct,
        wt.average_grade_points,
        cast(null as numeric) as average_ucas_points,

        -- Value-added metrics
        wt.va_score,
        wt.va_residual,
        wt.va_band,
        wt.va_percentile,
        wt.va_confidence_lower,
        wt.va_confidence_upper,

        -- National benchmarks
        wt.national_pass_rate_pct,
        wt.national_high_grade_pct,
        wt.national_va_average,

        -- Variance from benchmark
        wt.pass_rate_pct - wt.national_pass_rate_pct as pass_rate_vs_national_pct,
        wt.high_grade_rate_pct - wt.national_high_grade_pct as high_grade_vs_national_pct,
        wt.va_score - wt.national_va_average as va_vs_national,

        -- Subject ranking
        cast(null as int64) as subject_rank_internal,
        wt.subject_rank_national,

        -- Trend indicators
        case
            when wt.yoy_change_pct > 2 then 'Improving'
            when wt.yoy_change_pct < -2 then 'Declining'
            else 'Stable'
        end as performance_trajectory,
        wt.yoy_change_pct,

        -- Metadata
        wt.report_date,
        wt.record_source,
        wt.loaded_at

    from with_trajectory wt
    inner join dim_academic_year ay
        on wt.academic_year_id = ay.academic_year_id
    left join subject_mapping sm
        on wt.academic_year_id = sm.academic_year_id
        and wt.six_dimensions_subject_name = sm.six_dimensions_subject_name

)

select * from final
