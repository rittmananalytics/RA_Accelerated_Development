{{
    config(
        materialized='table',
        tags=['dimensions', 'marts']
    )
}}

{#-
Offering dimension linking courses to specific academic years.
Grain: One row per offering.
-#}

with source as (

    select * from {{ ref('stg_prosolution__offering') }}
    where is_valid_qualification = true

),

subject_crosswalk as (

    select * from {{ ref('seed_subject_crosswalk') }}

),

final as (

    select
        -- Surrogate key
        {{ generate_int_surrogate_key(['o.offering_id']) }} as offering_key,

        -- Natural key
        o.offering_id,

        -- Attributes
        o.offering_code,
        o.offering_name,
        o.qualification_id,
        o.study_year,
        o.duration_years,
        o.is_final_year,

        -- Foreign keys (natural keys for joins)
        o.academic_year_id,
        o.offering_type_id,
        o.course_header_id,

        -- External system mappings for benchmarking (from crosswalk)
        sc.dfe_qualification_code,
        sc.alps_subject_name,
        sc.six_dimensions_subject_name,

        -- Metadata
        o.record_source,
        o.loaded_at

    from source o
    left join subject_crosswalk sc
        on o.course_header_id = sc.course_header_id

)

select * from final
