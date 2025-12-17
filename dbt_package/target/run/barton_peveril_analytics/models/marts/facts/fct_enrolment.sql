
  
    

    create or replace table `ra-warehouse-dev`.`analytics`.`fct_enrolment`
      
    partition by date_trunc(academic_year_start_date, year)
    cluster by offering_key, student_key

    
    OPTIONS()
    as (
      with enrolment_context as (

    select * from `ra-warehouse-dev`.`analytics_integration`.`int_enrolment_with_context`

),

dim_academic_year as (

    select * from `ra-warehouse-dev`.`analytics`.`dim_academic_year`

),

dim_offering_type as (

    select * from `ra-warehouse-dev`.`analytics`.`dim_offering_type`

),

dim_course_header as (

    select * from `ra-warehouse-dev`.`analytics`.`dim_course_header`

),

dim_offering as (

    select * from `ra-warehouse-dev`.`analytics`.`dim_offering`

),

dim_student as (

    select * from `ra-warehouse-dev`.`analytics`.`dim_student`

),

dim_student_detail as (

    select * from `ra-warehouse-dev`.`analytics`.`dim_student_detail`

),

dim_prior_attainment as (

    select * from `ra-warehouse-dev`.`analytics`.`dim_prior_attainment`

),

dim_grade as (

    select * from `ra-warehouse-dev`.`analytics`.`dim_grade`

),

final as (

    select
        -- Primary key
        farm_fingerprint(
        concat(
            
                coalesce(cast(ec.enrolment_id as string), '_dbt_null_')
                
            
        )
    )
 as enrolment_key,

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
        ec.target_grade,
        ec.predicted_grade,

        -- A-Level grade flags
        ec.is_grade_a_star,
        ec.is_grade_a,
        ec.is_grade_b,
        ec.is_grade_c,
        ec.is_grade_d,
        ec.is_grade_e,
        ec.is_grade_u,

        -- BTEC grade flags
        ec.is_grade_distinction_star,
        ec.is_grade_distinction,
        ec.is_grade_merit,
        ec.is_grade_pass,

        -- Cumulative grade flags
        ec.is_high_grade,
        ec.is_pass,

        -- Prior attainment
        ec.average_gcse_score,
        ec.prior_attainment_band,

        -- Demographics
        ec.gender,
        ec.ethnicity,
        ec.is_send,
        ec.is_free_meals,
        ec.is_bursary,
        ec.is_lac,
        ec.is_young_carer,

        -- Attendance
        ec.attendance_pct,

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
    left join dim_student_detail sd
        on ec.student_detail_id = sd.student_detail_id
    left join dim_prior_attainment pa
        on ec.student_id = pa.student_id
        and ec.academic_year_id = pa.academic_year_id
    left join dim_grade g
        on ec.grade = g.grade
        and ec.grading_scale = g.grading_scale

)

select * from final
    );
  