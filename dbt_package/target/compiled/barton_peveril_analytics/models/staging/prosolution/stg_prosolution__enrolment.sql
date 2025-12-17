

with source as (

    select * from `ra-warehouse-dev`.`analytics_seed_raw_prosolution`.`enrolment`

),

renamed as (

    select
        -- Primary key
        enrolment_id,

        -- Foreign keys
        student_id,
        offering_id,
        completion_status_id,

        -- Dates
        enrolment_date,
        expected_end_date,
        actual_end_date,

        -- Grade attributes
        nullif(trim(target_grade), '')                  as target_grade,
        nullif(trim(predicted_grade), '')              as predicted_grade,
        nullif(trim(actual_grade), '')                 as actual_grade,

        -- Attendance
        safe_cast(attendance_pct as numeric)           as attendance_pct,

        -- Status flag
        coalesce(is_current, false)                    as is_current,

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