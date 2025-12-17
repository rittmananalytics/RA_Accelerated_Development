{{
    config(
        materialized='view',
        tags=['staging', 'focus']
    )
}}

with source as (

    select * from {{ source('raw_focus', 'average_gcse') }}

),

renamed as (

    select
        -- Foreign key
        student_id,

        -- GCSE score
        cast(average_gcse as numeric)                   as average_gcse_score,

        -- Prior attainment band based on thresholds
        -- Low: < 4.77, Mid: 4.77-6.09, High: > 6.09
        case
            when average_gcse is null or average_gcse = 0 then 'N/A'
            when average_gcse < {{ var('prior_attainment_low_threshold') }} then 'Low'
            when average_gcse <= {{ var('prior_attainment_high_threshold') }} then 'Mid'
            else 'High'
        end                                             as prior_attainment_band,

        -- Numeric band code for sorting
        case
            when average_gcse is null or average_gcse = 0 then 0
            when average_gcse < {{ var('prior_attainment_low_threshold') }} then 1
            when average_gcse <= {{ var('prior_attainment_high_threshold') }} then 2
            else 3
        end                                             as prior_attainment_band_code,

        -- Individual subject grades (if available)
        gcse_english_grade,
        gcse_english_points,
        gcse_maths_grade,
        gcse_maths_points,

        -- Aggregates
        total_gcse_points,
        gcse_count,
        gcse_a_star_to_c_count,

        -- Source info
        gcse_year,
        data_source,

        -- Metadata
        'focus'                                         as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from renamed
