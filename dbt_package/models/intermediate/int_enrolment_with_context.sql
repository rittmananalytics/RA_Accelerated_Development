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
        e.student_detail_id,

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
        e.grade,
        e.grade_date,
        e.predicted_grade,

        -- Grade points (calculated)
        {{ get_grade_points('e.grade', 'o.offering_type_id') }} as grade_points,
        {{ get_ucas_points('e.grade', 'o.offering_type_id') }} as ucas_points,

        -- A-Level grade flags
        case when o.offering_type_id in (1, 2) then
            case when e.grade = 'A*' then 1 else 0 end
        else 0 end                                      as is_grade_a_star,
        case when o.offering_type_id in (1, 2) then
            case when e.grade = 'A' then 1 else 0 end
        else 0 end                                      as is_grade_a,
        case when o.offering_type_id in (1, 2) then
            case when e.grade = 'B' then 1 else 0 end
        else 0 end                                      as is_grade_b,
        case when o.offering_type_id in (1, 2) then
            case when e.grade = 'C' then 1 else 0 end
        else 0 end                                      as is_grade_c,
        case when o.offering_type_id in (1, 2) then
            case when e.grade = 'D' then 1 else 0 end
        else 0 end                                      as is_grade_d,
        case when o.offering_type_id in (1, 2) then
            case when e.grade = 'E' then 1 else 0 end
        else 0 end                                      as is_grade_e,
        case when o.offering_type_id in (1, 2) then
            case when e.grade = 'U' then 1 else 0 end
        else 0 end                                      as is_grade_u,
        case when e.grade in ('X', '') or e.grade is null then 1 else 0 end as is_grade_x,

        -- BTEC grade flags
        case when o.offering_type_id in (4, 8, 9) then
            case when e.grade = 'D*' then 1 else 0 end
        else 0 end                                      as is_grade_distinction_star,
        case when o.offering_type_id in (4, 8, 9) then
            case when e.grade = 'D' then 1 else 0 end
        else 0 end                                      as is_grade_distinction,
        case when o.offering_type_id in (4, 8, 9) then
            case when e.grade = 'M' then 1 else 0 end
        else 0 end                                      as is_grade_merit,
        case when o.offering_type_id in (4, 8, 9) then
            case when e.grade = 'P' then 1 else 0 end
        else 0 end                                      as is_grade_pass,

        -- Cumulative grade flags (A-Level)
        case when e.grade in ('A*', 'A') then 1 else 0 end as is_grade_a_star_to_a,
        case when e.grade in ('A*', 'A', 'B') then 1 else 0 end as is_grade_a_star_to_b,
        case when e.grade in ('A*', 'A', 'B', 'C') then 1 else 0 end as is_grade_a_star_to_c,
        case when e.grade in ('A*', 'A', 'B', 'C', 'D', 'E') then 1 else 0 end as is_grade_a_star_to_e,

        -- High grade flag (depends on qualification type)
        case
            when o.offering_type_id in (1, 2) and e.grade in ('A*', 'A', 'B') then 1
            when o.offering_type_id in (4, 8, 9) and e.grade in ('D*', 'D', 'M') then 1
            else 0
        end                                             as is_high_grade,

        -- Pass flag
        case
            when o.offering_type_id in (1, 2) and e.grade in ('A*', 'A', 'B', 'C', 'D', 'E') then 1
            when o.offering_type_id in (4, 8, 9) and e.grade in ('D*', 'D', 'M', 'P') then 1
            else 0
        end                                             as is_pass,

        -- Student demographics
        sd.student_id,
        sd.gender_code,
        sd.gender,
        sd.ethnicity_group,
        sd.is_disadvantaged,
        sd.is_sen,
        sd.is_pp_or_fcm,
        sd.is_pupil_premium,
        sd.is_free_school_meals,
        sd.is_access_plus,

        -- Demographic flags as integers for aggregation
        case when sd.gender_code = 'M' then 1 else 0 end as is_male,
        case when sd.gender_code = 'F' then 1 else 0 end as is_female,
        case when sd.is_disadvantaged then 1 else 0 end as is_disadvantaged_int,
        case when sd.is_sen then 1 else 0 end           as is_sen_int,
        case when sd.is_pp_or_fcm then 1 else 0 end     as is_pp_or_fcm_int,
        case when sd.is_access_plus then 1 else 0 end   as is_access_plus_int,

        -- Prior attainment
        sd.average_gcse_score,
        sd.prior_attainment_band,
        sd.prior_attainment_band_code,
        case when sd.prior_attainment_band = 'Low' then 1 else 0 end as is_prior_low,
        case when sd.prior_attainment_band = 'Mid' then 1 else 0 end as is_prior_mid,
        case when sd.prior_attainment_band = 'High' then 1 else 0 end as is_prior_high,
        case when sd.prior_attainment_band = 'N/A' then 1 else 0 end as is_prior_na,

        -- Re-sit tracking
        case when e.is_resit = false then true else false end as is_first_sit,
        e.is_resit,
        e.original_enrolment_id,

        -- Component grades for variance analysis
        e.component_1_grade,
        e.component_2_grade,
        e.component_3_grade,
        e.coursework_grade,
        e.exam_grade,

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
    inner join student_demographics sd
        on e.student_detail_id = sd.student_detail_id

    -- Filter to final year only (where results are awarded)
    where o.is_final_year = true

)

select * from enriched
