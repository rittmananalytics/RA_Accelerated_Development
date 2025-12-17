{{
    config(
        materialized='table',
        tags=['facts', 'marts', 'external_benchmark'],
        cluster_by=['academic_year_key', 'demographic_category']
    )
}}

{#-
Demographic equity gap analysis from JEDI reports.
Grain: One row per demographic category/value per academic year.
-#}

with jedi_data as (

    select * from {{ ref('stg_six_dimensions__jedi') }}

),

dim_academic_year as (

    select * from {{ ref('dim_academic_year') }}

),

-- Calculate overall cohort metrics for gap analysis
overall_metrics as (

    select
        academic_year_id,
        sum(cohort_count) as total_cohort_count,
        -- Weighted average pass rate
        safe_divide(
            sum(pass_rate_pct * cohort_count),
            sum(cohort_count)
        ) as overall_pass_rate_pct,
        safe_divide(
            sum(high_grade_rate_pct * cohort_count),
            sum(cohort_count)
        ) as overall_high_grade_pct,
        safe_divide(
            sum(va_score * cohort_count),
            sum(cohort_count)
        ) as overall_va_score

    from jedi_data
    group by academic_year_id

),

-- Get prior year gaps for trend analysis
with_prior_year as (

    select
        jd.*,
        lag(jd.gap_vs_overall_pct) over (
            partition by jd.demographic_category, jd.demographic_value
            order by jd.academic_year_id
        ) as prior_year_gap_pct

    from jedi_data jd

),

final as (

    select
        -- Surrogate key
        {{ generate_int_surrogate_key(['wp.academic_year_id', 'wp.demographic_category', 'wp.demographic_value']) }} as equity_gap_key,

        -- Dimension foreign key
        ay.academic_year_key,

        -- Source identifier
        'JEDI' as report_type,

        -- Demographic segmentation
        wp.demographic_category,
        wp.demographic_value,

        -- Intersectional analysis (not available in current data)
        cast(null as string) as demographic_category_2,
        cast(null as string) as demographic_value_2,
        false as is_intersectional,

        -- Cohort metrics
        wp.cohort_count as subgroup_cohort_count,
        wp.cohort_pct as subgroup_cohort_pct,

        -- Subgroup attainment
        wp.pass_rate_pct as subgroup_pass_rate_pct,
        wp.high_grade_rate_pct as subgroup_high_grade_pct,
        wp.average_points as subgroup_avg_grade_points,
        cast(null as numeric) as subgroup_avg_ucas_points,

        -- Subgroup value-added
        wp.va_score as subgroup_va_score,
        wp.va_band as subgroup_va_band,
        cast(null as numeric) as subgroup_va_percentile,

        -- Overall cohort benchmarks
        om.overall_pass_rate_pct,
        om.overall_high_grade_pct,
        om.overall_va_score,

        -- Gap calculations (subgroup - overall)
        wp.gap_vs_overall_pct as pass_rate_gap_pct,
        wp.high_grade_rate_pct - om.overall_high_grade_pct as high_grade_gap_pct,
        wp.va_score - om.overall_va_score as va_gap,

        -- Gender-specific gaps (placeholders - need separate calculation)
        cast(null as numeric) as male_pass_rate_pct,
        cast(null as numeric) as female_pass_rate_pct,
        cast(null as numeric) as gender_gap_pass_rate_pct,
        cast(null as numeric) as male_high_grade_pct,
        cast(null as numeric) as female_high_grade_pct,
        cast(null as numeric) as gender_gap_high_grade_pct,

        -- National benchmarks
        wp.national_pass_rate_pct as national_subgroup_pass_rate_pct,
        wp.national_high_grade_pct as national_subgroup_high_grade_pct,
        cast(null as numeric) as national_subgroup_va,

        -- Performance vs national
        wp.gap_vs_national_pct as pass_rate_vs_national_pct,
        cast(null as numeric) as high_grade_vs_national_pct,
        cast(null as numeric) as va_vs_national,

        -- Gap trend analysis
        wp.prior_year_gap_pct,
        wp.gap_vs_overall_pct - wp.prior_year_gap_pct as gap_change_yoy_pct,
        case
            when wp.gap_vs_overall_pct - wp.prior_year_gap_pct < -1 then 'Narrowing'
            when wp.gap_vs_overall_pct - wp.prior_year_gap_pct > 1 then 'Widening'
            else 'Stable'
        end as gap_trend,

        -- Metadata
        wp.report_date,
        wp.record_source,
        wp.loaded_at

    from with_prior_year wp
    inner join dim_academic_year ay
        on wp.academic_year_id = ay.academic_year_id
    left join overall_metrics om
        on wp.academic_year_id = om.academic_year_id

)

select * from final
