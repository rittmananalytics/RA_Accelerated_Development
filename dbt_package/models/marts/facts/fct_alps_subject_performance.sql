{{
    config(
        materialized='table',
        tags=['facts', 'marts', 'external_benchmark'],
        cluster_by=['academic_year_key', 'alps_subject_name']
    )
}}

{#-
ALPS subject-level benchmarking fact table.
Grain: One row per subject per academic year.
Note: Different grain from fct_enrolment (aggregate, not student-level).
-#}

with alps_performance as (

    select * from {{ ref('int_alps_performance_unioned') }}

),

dim_academic_year as (

    select * from {{ ref('dim_academic_year') }}

),

dim_offering as (

    select * from {{ ref('dim_offering') }}

),

-- Attempt to match ALPS subjects to internal offerings
subject_mapping as (

    select
        ap.academic_year_id,
        ap.alps_subject_name,
        ap.qualification_type,
        o.offering_key,
        o.offering_id,
        -- Simple mapping status based on whether match found
        case
            when o.offering_key is not null then 'Matched'
            else 'Unmapped'
        end as subject_mapping_status,
        case
            when o.offering_key is not null then 100.0
            else 0.0
        end as mapping_confidence_pct

    from alps_performance ap
    left join dim_offering o
        on ap.alps_subject_name = o.alps_subject_name
        and ap.academic_year_id = o.academic_year_id

),

final as (

    select
        -- Surrogate key
        {{ generate_int_surrogate_key(['ap.academic_year_id', 'ap.alps_subject_name', 'ap.qualification_type']) }} as alps_subject_performance_key,

        -- Dimension foreign keys
        ay.academic_year_key,
        sm.offering_key,

        -- ALPS identifiers
        ap.alps_subject_name,
        ap.qualification_type as alps_qualification_type,

        -- Subject mapping
        sm.subject_mapping_status,
        sm.mapping_confidence_pct,

        -- Cohort
        ap.cohort_count,

        -- A-Level grade distribution (counts)
        ap.grade_a_star_count,
        ap.grade_a_count,
        ap.grade_b_count,
        ap.grade_c_count,
        ap.grade_d_count,
        ap.grade_e_count,
        ap.grade_u_count,
        cast(null as int64) as grade_x_count,

        -- A-Level grade distribution (percentages)
        ap.grade_a_star_pct,
        ap.grade_a_pct,
        ap.grade_b_pct,
        ap.grade_c_pct,
        ap.grade_d_pct,
        ap.grade_e_pct,
        ap.grade_u_pct,
        cast(null as numeric) as grade_x_pct,

        -- BTEC Single Award distribution (counts)
        ap.btec_distinction_star_count,
        ap.btec_distinction_count,
        ap.btec_merit_count,
        ap.btec_pass_count,

        -- BTEC Single Award distribution (percentages)
        ap.btec_distinction_star_pct,
        ap.btec_distinction_pct,
        ap.btec_merit_pct,
        ap.btec_pass_pct,

        -- BTEC Double Award (not in current model but placeholders)
        cast(null as int64) as btec_d_star_d_star_count,
        cast(null as int64) as btec_d_star_d_count,
        cast(null as int64) as btec_dd_count,
        cast(null as int64) as btec_dm_count,
        cast(null as int64) as btec_mm_count,
        cast(null as int64) as btec_mp_count,
        cast(null as int64) as btec_pp_count,

        cast(null as numeric) as btec_d_star_d_star_pct,
        cast(null as numeric) as btec_d_star_d_pct,
        cast(null as numeric) as btec_dd_pct,
        cast(null as numeric) as btec_dm_pct,
        cast(null as numeric) as btec_mm_pct,
        cast(null as numeric) as btec_mp_pct,
        cast(null as numeric) as btec_pp_pct,

        -- Cumulative metrics
        ap.a_star_to_a_pct,
        ap.a_star_to_b_pct,
        ap.a_star_to_c_pct,
        ap.a_star_to_e_pct,
        ap.high_grade_pct,
        ap.pass_rate_pct,

        -- ALPS benchmarking metrics
        ap.alps_band,
        ap.alps_score,
        cast(null as numeric) as alps_national_percentile,

        -- Averages
        ap.average_grade_points,
        cast(null as numeric) as average_ucas_points,

        -- Completion
        cast(null as numeric) as completion_rate_pct,

        -- Metadata
        ap.report_date as alps_report_date,
        ap.record_source,
        ap.loaded_at

    from alps_performance ap
    inner join dim_academic_year ay
        on ap.academic_year_id = ay.academic_year_id
    left join subject_mapping sm
        on ap.academic_year_id = sm.academic_year_id
        and ap.alps_subject_name = sm.alps_subject_name
        and ap.qualification_type = sm.qualification_type

)

select * from final
