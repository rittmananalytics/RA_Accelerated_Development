{{
    config(
        materialized='view',
        tags=['staging', 'mis_applications']
    )
}}

with source as (

    select * from {{ source('raw_mis_applications', 'student_extended_data') }}

),

renamed as (

    select
        -- Foreign key
        student_detail_id,

        -- Disadvantage flag (ED = Economically Disadvantaged)
        case when ed = 1 then true else false end       as is_disadvantaged,

        -- SEN flag (includes Additional Adjustments)
        case when sen = 1 then true else false end      as is_sen,

        -- Pupil Premium / Free School Meals
        case when pp_or_fcm = 1 then true else false end as is_pp_or_fcm,
        coalesce(is_pupil_premium, false)               as is_pupil_premium,
        coalesce(is_free_school_meals, false)           as is_free_school_meals,

        -- Bursary
        coalesce(is_bursary, false)                     as is_bursary_recipient,
        bursary_type,

        -- Access arrangements
        coalesce(is_access_plus, false)                 as is_access_plus,
        coalesce(has_additional_adjustments, false)     as has_additional_adjustments,

        -- EHCP
        coalesce(has_ehcp, false)                       as has_ehcp,

        -- Looked After Children
        coalesce(is_lac, false)                         as is_lac,
        coalesce(is_care_leaver, false)                 as is_care_leaver,

        -- Young Carer
        coalesce(is_young_carer, false)                 as is_young_carer,

        -- SEND type
        sen_type,

        -- Metadata
        'mis_applications'                              as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from renamed
