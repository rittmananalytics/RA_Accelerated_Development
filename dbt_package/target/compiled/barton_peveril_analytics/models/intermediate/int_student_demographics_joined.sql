with student as (

    select * from `ra-warehouse-dev`.`analytics_staging`.`stg_prosolution__student`

),

student_detail as (

    select * from `ra-warehouse-dev`.`analytics_staging`.`stg_prosolution__student_detail`

),

extended_data as (

    select * from `ra-warehouse-dev`.`analytics_staging`.`stg_mis_applications__student_extended_data`

),

prior_attainment as (

    select * from `ra-warehouse-dev`.`analytics_staging`.`stg_focus__average_gcse`

),

joined as (

    select
        -- Keys
        sd.student_detail_id,
        sd.student_id,
        sd.academic_year_id,

        -- Core demographics from student master
        s.first_name,
        s.last_name,
        s.full_name,
        s.date_of_birth,
        s.gender,
        s.ethnicity,
        s.is_active,

        -- Location from student_detail
        sd.postcode,
        sd.postcode_area,

        -- SEND flags from student_detail
        sd.lldd_code,
        sd.is_send,
        sd.is_high_needs,
        sd.primary_send_type,
        sd.secondary_send_type,

        -- Disadvantage flags from student_detail
        sd.is_free_meals,
        sd.is_bursary,
        sd.is_lac,

        -- Extended demographics from MIS Applications
        ed.nationality,
        ed.country_of_birth,
        ed.first_language,
        ed.religion,
        coalesce(ed.is_young_carer, false)              as is_young_carer,
        coalesce(ed.is_parent_carer, false)             as is_parent_carer,
        ed.care_leaver_status,
        ed.household_situation,
        ed.imd_decile,
        ed.polar4_quintile,
        ed.tundra_classification,

        -- Prior attainment from Focus
        pa.average_gcse_score,
        pa.prior_attainment_band,
        pa.prior_attainment_band_code,
        pa.gcse_english_grade,
        pa.gcse_maths_grade,
        pa.gcse_count,

        -- Metadata
        sd.record_source,
        sd.loaded_at

    from student_detail sd
    inner join student s
        on sd.student_id = s.student_id
    left join extended_data ed
        on sd.student_id = ed.student_id
        and sd.academic_year_id = ed.academic_year_id
    left join prior_attainment pa
        on sd.student_id = pa.student_id
        and sd.academic_year_id = pa.academic_year_id

)

select * from joined