{{
    config(
        materialized='table',
        tags=['facts', 'marts'],
        partition_by={
            'field': 'academic_year_start_date',
            'data_type': 'date',
            'granularity': 'year'
        },
        cluster_by=['offering_key', 'student_key']
    )
}}

{#-
Student enrolment fact table at student-offering grain.
Primary fact table for internal student performance analysis.
-#}

with enrolment_context as (

    select * from {{ ref('int_enrolment_with_context') }}

),

dim_academic_year as (

    select * from {{ ref('dim_academic_year') }}

),

dim_offering_type as (

    select * from {{ ref('dim_offering_type') }}

),

dim_course_header as (

    select * from {{ ref('dim_course_header') }}

),

dim_offering as (

    select * from {{ ref('dim_offering') }}

),

dim_student as (

    select * from {{ ref('dim_student') }}

),

dim_student_detail as (

    select * from {{ ref('dim_student_detail') }}

),

dim_prior_attainment as (

    select * from {{ ref('dim_prior_attainment') }}

),

dim_grade as (

    select * from {{ ref('dim_grade') }}

),

final as (

    select
        -- Primary key
        {{ generate_int_surrogate_key(['ec.enrolment_id']) }} as enrolment_key,

        -- Dimension foreign keys (surrogate)
        ay.academic_year_key,
        ot.offering_type_key,
        ch.course_header_key,
        o.offering_key,
        s.student_key,
        sd.student_detail_key,
        pa.prior_attainment_key,
        g.grade_key,

        -- Natural keys (for debugging)
        ec.academic_year_id,
        ec.offering_id,
        ec.student_id,
        ec.student_detail_id,

        -- For partitioning
        ay.academic_year_start_date,

        -- Enrolment status
        ec.completion_status_id,
        ec.completion_status,
        ec.is_completed,

        -- Grade measures
        ec.grade,
        ec.grade_points,
        ec.ucas_points,

        -- A-Level grade flags
        ec.is_grade_a_star,
        ec.is_grade_a,
        ec.is_grade_b,
        ec.is_grade_c,
        ec.is_grade_d,
        ec.is_grade_e,
        ec.is_grade_u,
        ec.is_grade_x,

        -- BTEC grade flags
        ec.is_grade_distinction_star,
        ec.is_grade_distinction,
        ec.is_grade_merit,
        ec.is_grade_pass,

        -- Cumulative grade flags
        ec.is_high_grade,
        ec.is_pass,
        ec.is_grade_a_star_to_a,
        ec.is_grade_a_star_to_b,
        ec.is_grade_a_star_to_c,
        ec.is_grade_a_star_to_e,

        -- Prior attainment
        ec.average_gcse_score,
        ec.prior_attainment_band,
        ec.is_prior_low,
        ec.is_prior_mid,
        ec.is_prior_high,
        ec.is_prior_na,

        -- Demographics
        ec.gender,
        ec.is_male,
        ec.is_female,
        ec.is_disadvantaged_int as is_disadvantaged,
        ec.is_pp_or_fcm_int as is_pupil_premium,
        cast(null as int64) as is_free_school_meals,  -- Need separate flag
        ec.is_sen_int as is_sen,
        ec.is_access_plus_int as is_access_plus,
        ec.ethnicity_group,

        -- Re-sit tracking
        ec.is_first_sit,
        ec.is_resit,
        cast(null as string) as previous_grade,
        cast(null as int64) as previous_grade_points,
        cast(null as int64) as grade_improvement_points,
        cast(null as int64) as time_to_resit_years,

        -- Value-added (placeholder for future calculation)
        cast(null as string) as target_grade,
        cast(null as int64) as target_grade_points,
        cast(null as numeric) as value_added_points,

        -- Counting measure
        ec.enrolment_count,

        -- Metadata
        ec.record_source,
        ec.loaded_at

    from enrolment_context ec

    -- Join to dimensions
    inner join dim_academic_year ay
        on ec.academic_year_id = ay.academic_year_id
    inner join dim_offering_type ot
        on ec.offering_type_id = ot.offering_type_id
    inner join dim_course_header ch
        on ec.course_header_id = ch.course_header_id
    inner join dim_offering o
        on ec.offering_id = o.offering_id
    inner join dim_student s
        on ec.student_id = s.student_id
    inner join dim_student_detail sd
        on ec.student_detail_id = sd.student_detail_id
    left join dim_prior_attainment pa
        on ec.student_id = pa.student_id
    left join dim_grade g
        on ec.grade = g.grade
        and ec.grading_scale = g.grading_scale

)

select * from final
