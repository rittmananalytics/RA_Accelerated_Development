{{
    config(
        materialized='view',
        tags=['intermediate']
    )
}}

{#-
Enriches enrolment data with offering, student demographics, and calculates
grade metrics. This is the main integration model that feeds the fact table.
-#}

with enrolment as (

    select * from {{ ref('stg_prosolution__enrolment') }}
    where is_valid_completion = true

),

offering as (

    select * from {{ ref('stg_prosolution__offering') }}
    where is_valid_qualification = true

),

offering_type as (

    select * from {{ ref('stg_prosolution__offering_type') }}

),

course_header as (

    select * from {{ ref('stg_prosolution__course_header') }}

),

completion_status as (

    select * from {{ ref('stg_prosolution__completion_status') }}

),

student_demographics as (

    select * from {{ ref('int_student_demographics_joined') }}

),

enriched as (

    select
        -- Enrolment keys
        e.enrolment_id,
        e.offering_id,
        e.student_id,

        -- Offering context
        o.course_header_id,
        o.offering_type_id,
        o.academic_year_id,
        o.offering_code,
        o.offering_name,
        o.qualification_id,
        o.study_year,
        o.duration_years,
        o.is_final_year,

        -- Offering type context
        ot.offering_type_name,
        ot.offering_type_category,
        ot.grading_scale,
        ot.is_academic,
        ot.is_vocational,

        -- Course header context
        ch.course_code,
        ch.course_name,
        ch.subject_area,
        ch.department,

        -- Completion status
        e.completion_status_id,
        cs.status_name                                  as completion_status,
        cs.is_completed,
        cs.is_continuing,
        cs.is_withdrawn,

        -- Grade
        e.actual_grade                                  as grade,
        e.target_grade,
        e.predicted_grade,

        -- Attendance
        e.attendance_pct,

        -- Dates
        e.enrolment_date,
        e.expected_end_date,
        e.actual_end_date,

        -- A-Level grade flags
        case when ot.is_academic and e.actual_grade = 'A*' then 1 else 0 end as is_grade_a_star,
        case when ot.is_academic and e.actual_grade = 'A' then 1 else 0 end as is_grade_a,
        case when ot.is_academic and e.actual_grade = 'B' then 1 else 0 end as is_grade_b,
        case when ot.is_academic and e.actual_grade = 'C' then 1 else 0 end as is_grade_c,
        case when ot.is_academic and e.actual_grade = 'D' then 1 else 0 end as is_grade_d,
        case when ot.is_academic and e.actual_grade = 'E' then 1 else 0 end as is_grade_e,
        case when ot.is_academic and e.actual_grade = 'U' then 1 else 0 end as is_grade_u,

        -- BTEC grade flags
        case when ot.is_vocational and e.actual_grade = 'D*' then 1 else 0 end as is_grade_distinction_star,
        case when ot.is_vocational and e.actual_grade = 'D' then 1 else 0 end as is_grade_distinction,
        case when ot.is_vocational and e.actual_grade = 'M' then 1 else 0 end as is_grade_merit,
        case when ot.is_vocational and e.actual_grade = 'P' then 1 else 0 end as is_grade_pass,

        -- High grade flag (depends on qualification type)
        case
            when ot.is_academic and e.actual_grade in ('A*', 'A', 'B') then 1
            when ot.is_vocational and e.actual_grade in ('D*', 'D', 'M') then 1
            else 0
        end                                             as is_high_grade,

        -- Pass flag
        case
            when ot.is_academic and e.actual_grade in ('A*', 'A', 'B', 'C', 'D', 'E') then 1
            when ot.is_vocational and e.actual_grade in ('D*', 'D', 'M', 'P') then 1
            else 0
        end                                             as is_pass,

        -- Student demographics
        sd.student_detail_id,
        sd.full_name                                    as student_name,
        sd.gender,
        sd.ethnicity,
        sd.is_send,
        sd.is_free_meals,
        sd.is_bursary,
        sd.is_lac,
        sd.is_young_carer,

        -- Prior attainment
        sd.average_gcse_score,
        sd.prior_attainment_band,
        sd.prior_attainment_band_code,

        -- Counting measure
        1                                               as enrolment_count,

        -- Metadata
        e.record_source,
        e.loaded_at

    from enrolment e
    inner join offering o
        on e.offering_id = o.offering_id
    inner join offering_type ot
        on o.offering_type_id = ot.offering_type_id
    inner join course_header ch
        on o.course_header_id = ch.course_header_id
    left join completion_status cs
        on e.completion_status_id = cs.completion_status_id
    left join student_demographics sd
        on e.student_id = sd.student_id
        and o.academic_year_id = sd.academic_year_id

    -- Filter to final year only (where results are awarded)
    where o.is_final_year = true

)

select * from enriched
