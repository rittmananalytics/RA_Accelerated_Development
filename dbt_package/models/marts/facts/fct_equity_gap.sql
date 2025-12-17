{{
    config(
        materialized='table',
        tags=['facts', 'marts', 'external_benchmark'],
        cluster_by=['academic_year_key', 'dimension_name']
    )
}}

{#-
Demographic equity gap analysis from JEDI reports.
Grain: One row per demographic comparison per academic year.
-#}

with jedi_data as (

    select * from {{ ref('stg_six_dimensions__jedi') }}

),

dim_academic_year as (

    select * from {{ ref('dim_academic_year') }}

),

-- Get prior year gaps for trend analysis
with_prior_year as (

    select
        jd.*,
        lag(jd.gap_grade_points) over (
            partition by jd.dimension_name, jd.student_group
            order by jd.academic_year_id
        ) as prior_year_gap

    from jedi_data jd

),

final as (

    select
        -- Surrogate key
        {{ generate_int_surrogate_key(['wp.academic_year_id', 'wp.jedi_report_id']) }} as equity_gap_key,

        -- Dimension foreign key
        ay.academic_year_key,

        -- Source identifier
        wp.report_type,
        wp.dimension_name,

        -- Group comparison
        wp.student_group,
        wp.comparison_group,

        -- Cohort metrics
        wp.student_count,
        wp.comparison_count,

        -- Performance metrics
        wp.student_avg_grade_points,
        wp.comparison_avg_grade_points,

        -- Gap analysis
        wp.gap_grade_points,
        wp.gap_significance,
        wp.performance_band,

        -- Trend indicators
        wp.prior_year_gap,
        wp.gap_grade_points - wp.prior_year_gap as gap_change_yoy,
        case
            when abs(wp.gap_grade_points) < abs(wp.prior_year_gap) then 'Narrowing'
            when abs(wp.gap_grade_points) > abs(wp.prior_year_gap) then 'Widening'
            else 'Stable'
        end as gap_trend,

        -- Metadata
        wp.report_date,
        wp.record_source,
        wp.loaded_at

    from with_prior_year wp
    inner join dim_academic_year ay
        on wp.academic_year_id = ay.academic_year_id

)

select * from final
