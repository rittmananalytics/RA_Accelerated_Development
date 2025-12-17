{{
    config(
        materialized='view',
        tags=['intermediate']
    )
}}

{#-
Joins student detail with extended demographic data.
Creates a single view of all student demographics for a given academic year.
-#}

with student_detail as (

    select * from {{ ref('stg_prosolution__student_detail') }}

),

extended_data as (

    select * from {{ ref('stg_mis_applications__student_extended_data') }}

),

prior_attainment as (

    select * from {{ ref('stg_focus__average_gcse') }}

),

joined as (

    select
        -- Keys
        sd.student_detail_id,
        sd.student_id,
        sd.academic_year_id,

        -- Core demographics from student_detail
        sd.gender_code,
        sd.gender,
        sd.date_of_birth,
        sd.ethnicity_code,
        sd.ethnicity_description,
        sd.ethnicity_group,
        sd.postcode,
        sd.postcode_area,
        sd.is_current,

        -- Extended demographics from MIS Applications
        coalesce(ed.is_disadvantaged, false)            as is_disadvantaged,
        coalesce(ed.is_sen, false)                      as is_sen,
        coalesce(ed.is_pp_or_fcm, false)                as is_pp_or_fcm,
        coalesce(ed.is_pupil_premium, false)            as is_pupil_premium,
        coalesce(ed.is_free_school_meals, false)        as is_free_school_meals,
        coalesce(ed.is_bursary_recipient, false)        as is_bursary_recipient,
        coalesce(ed.is_access_plus, false)              as is_access_plus,
        coalesce(ed.has_additional_adjustments, false)  as has_additional_adjustments,
        coalesce(ed.has_ehcp, false)                    as has_ehcp,
        coalesce(ed.is_lac, false)                      as is_lac,
        coalesce(ed.is_care_leaver, false)              as is_care_leaver,
        coalesce(ed.is_young_carer, false)              as is_young_carer,
        ed.sen_type,
        ed.bursary_type,

        -- Prior attainment from Focus
        pa.average_gcse_score,
        pa.prior_attainment_band,
        pa.prior_attainment_band_code,
        pa.gcse_english_grade,
        pa.gcse_maths_grade,
        pa.total_gcse_points,
        pa.gcse_count,

        -- Metadata
        sd.record_source,
        sd.loaded_at

    from student_detail sd
    left join extended_data ed
        on sd.student_detail_id = ed.student_detail_id
    left join prior_attainment pa
        on sd.student_id = pa.student_id

)

select * from joined
