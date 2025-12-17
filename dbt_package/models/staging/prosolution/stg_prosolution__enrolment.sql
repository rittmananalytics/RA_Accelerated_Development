{{
    config(
        materialized='view',
        tags=['staging', 'prosolution']
    )
}}

with source as (

    select * from {{ source('raw_prosolution', 'enrolment') }}

),

renamed as (

    select
        -- Primary key
        enrolment_id,

        -- Foreign keys
        offering_id,
        student_detail_id,
        completion_status_id,

        -- Grade attributes
        nullif(trim(grade), '')                         as grade,
        grade_date,
        nullif(trim(predicted_grade), '')               as predicted_grade,

        -- Enrolment dates
        enrolment_date,
        withdrawal_date,
        withdrawal_reason,

        -- Component grades (for variance analysis)
        nullif(trim(component_1_grade), '')             as component_1_grade,
        nullif(trim(component_2_grade), '')             as component_2_grade,
        nullif(trim(component_3_grade), '')             as component_3_grade,
        nullif(trim(coursework_grade), '')              as coursework_grade,
        nullif(trim(exam_grade), '')                    as exam_grade,

        -- Re-sit tracking
        coalesce(is_resit, false)                       as is_resit,
        original_enrolment_id,

        -- Derived status flags
        case
            when completion_status_id in (1, 2) then true
            else false
        end                                             as is_valid_completion,

        -- Metadata
        'prosolution'                                   as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from renamed
