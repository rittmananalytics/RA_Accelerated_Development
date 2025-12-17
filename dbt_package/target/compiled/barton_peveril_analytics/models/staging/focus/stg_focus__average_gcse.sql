

with source as (

    select * from `ra-warehouse-dev`.`analytics_seed_raw_focus`.`average_gcse`

),

renamed as (

    select
        -- Primary key
        average_gcse_id,

        -- Foreign key
        student_id,
        academic_year_id,

        -- GCSE score
        cast(average_gcse_score as numeric)             as average_gcse_score,

        -- Prior attainment band based on thresholds
        -- Low: < 4.77, Mid: 4.77-6.09, High: > 6.09
        case
            when average_gcse_score is null or average_gcse_score = 0 then 'N/A'
            when average_gcse_score < 4.77 then 'Low'
            when average_gcse_score <= 6.09 then 'Mid'
            else 'High'
        end                                             as prior_attainment_band,

        -- Numeric band code for sorting
        case
            when average_gcse_score is null or average_gcse_score = 0 then 0
            when average_gcse_score < 4.77 then 1
            when average_gcse_score <= 6.09 then 2
            else 3
        end                                             as prior_attainment_band_code,

        -- Individual subject grades
        cast(gcse_english_grade as int64)               as gcse_english_grade,
        cast(gcse_maths_grade as int64)                 as gcse_maths_grade,

        -- Count
        cast(gcse_count as int64)                       as gcse_count,

        -- Source info
        data_source,

        -- Metadata
        'focus'                                         as record_source,
        current_timestamp()                             as loaded_at

    from source

)

select * from renamed