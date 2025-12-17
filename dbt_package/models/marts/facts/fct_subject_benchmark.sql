{{
    config(
        materialized='table',
        tags=['facts', 'marts', 'external_benchmark'],
        cluster_by=['academic_year_key', 'six_dimensions_subject_name']
    )
}}

{#-
Subject-level benchmarking from Six Dimensions reports.
Grain: One row per subject per report type per academic year.
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
            partition by sp.six_dimensions_subject_name, sp.report_type
            order by sp.academic_year_id
        ) as prior_year_pass_rate,
        sp.pass_rate_pct - lag(sp.pass_rate_pct) over (
            partition by sp.six_dimensions_subject_name, sp.report_type
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
        wt.average_gcse_on_entry,

        -- Performance metrics
        wt.pass_rate_pct,
        wt.high_grades_pct,
        wt.completion_rate_pct,
        wt.achievement_rate_pct,

        -- Value-added metrics (from VA reports)
        wt.value_added_score,
        wt.residual_score,
        wt.expected_grade,
        wt.actual_avg_grade,
        wt.performance_band,
        wt.confidence_interval_lower,
        wt.confidence_interval_upper,

        -- Sixth Sense metrics
        wt.performance_quartile,

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
