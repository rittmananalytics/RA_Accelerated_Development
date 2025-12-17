{{
    config(
        materialized='table',
        tags=['dimensions', 'marts']
    )
}}

{#-
Student dimension with SCD Type 2 history tracking.
Grain: One row per student per version.
-#}

with source as (

    select * from {{ ref('stg_prosolution__student') }}

),

student_detail as (

    select * from {{ ref('stg_prosolution__student_detail') }}

),

-- Get latest student detail for each student
latest_detail as (

    select
        student_id,
        gender_code,
        gender,
        max(academic_year_id) as latest_academic_year
    from student_detail
    group by student_id, gender_code, gender

),

final as (

    select
        -- Surrogate key
        {{ generate_int_surrogate_key(['s.student_id']) }} as student_key,

        -- Natural keys
        s.student_id,
        cast(null as int64) as student_detail_id,  -- Multiple details per student

        -- Attributes (from latest detail)
        ld.gender_code,
        ld.gender,

        -- SCD Type 2 tracking (simplified - single version per student)
        s.first_enrolment_date as valid_from_date,
        cast(null as date) as valid_to_date,
        true as is_current,

        -- Metadata
        s.record_source,
        s.loaded_at

    from source s
    left join latest_detail ld
        on s.student_id = ld.student_id

)

select * from final
