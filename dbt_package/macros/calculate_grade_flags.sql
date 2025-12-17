{% macro calculate_a_level_grade_flags(grade_column) %}
    {#-
    Generates grade flag columns for A-Level grades.
    Each flag is 1 if the grade matches, 0 otherwise.

    Args:
        grade_column: The column containing the grade

    Returns:
        Multiple columns for grade flags
    -#}

    -- Individual grade flags
    case when {{ grade_column }} = 'A*' then 1 else 0 end as is_grade_a_star,
    case when {{ grade_column }} = 'A' then 1 else 0 end as is_grade_a,
    case when {{ grade_column }} = 'B' then 1 else 0 end as is_grade_b,
    case when {{ grade_column }} = 'C' then 1 else 0 end as is_grade_c,
    case when {{ grade_column }} = 'D' then 1 else 0 end as is_grade_d,
    case when {{ grade_column }} = 'E' then 1 else 0 end as is_grade_e,
    case when {{ grade_column }} = 'U' then 1 else 0 end as is_grade_u,
    case when {{ grade_column }} in ('X', '') or {{ grade_column }} is null then 1 else 0 end as is_grade_x,

    -- Cumulative grade flags
    case when {{ grade_column }} in ('A*', 'A') then 1 else 0 end as is_grade_a_star_to_a,
    case when {{ grade_column }} in ('A*', 'A', 'B') then 1 else 0 end as is_grade_a_star_to_b,
    case when {{ grade_column }} in ('A*', 'A', 'B', 'C') then 1 else 0 end as is_grade_a_star_to_c,
    case when {{ grade_column }} in ('A*', 'A', 'B', 'C', 'D', 'E') then 1 else 0 end as is_grade_a_star_to_e,

    -- High grade and pass flags
    case when {{ grade_column }} in ('A*', 'A', 'B') then 1 else 0 end as is_high_grade,
    case when {{ grade_column }} in ('A*', 'A', 'B', 'C', 'D', 'E') then 1 else 0 end as is_pass

{% endmacro %}


{% macro calculate_btec_grade_flags(grade_column) %}
    {#-
    Generates grade flag columns for BTEC grades.

    Args:
        grade_column: The column containing the grade

    Returns:
        Multiple columns for BTEC grade flags
    -#}

    -- Single Award grade flags
    case when {{ grade_column }} = 'D*' then 1 else 0 end as is_grade_distinction_star,
    case when {{ grade_column }} = 'D' then 1 else 0 end as is_grade_distinction,
    case when {{ grade_column }} = 'M' then 1 else 0 end as is_grade_merit,
    case when {{ grade_column }} = 'P' then 1 else 0 end as is_grade_pass,

    -- High grade and pass flags for BTEC
    case when {{ grade_column }} in ('D*', 'D', 'M') then 1 else 0 end as is_high_grade,
    case when {{ grade_column }} in ('D*', 'D', 'M', 'P') then 1 else 0 end as is_pass

{% endmacro %}


{% macro get_grade_points(grade_column, offering_type_id_column) %}
    {#-
    Returns grade points based on grade and qualification type.

    Args:
        grade_column: The column containing the grade
        offering_type_id_column: The column containing offering type ID

    Returns:
        INT64 grade points
    -#}
    case
        -- A-Level grades (offering_type_id in 1, 2)
        when {{ offering_type_id_column }} in (1, 2) then
            case {{ grade_column }}
                when 'A*' then 60
                when 'A' then 50
                when 'B' then 40
                when 'C' then 30
                when 'D' then 20
                when 'E' then 10
                else 0
            end
        -- BTEC grades (offering_type_id in 4, 8, 9)
        when {{ offering_type_id_column }} in (4, 8, 9) then
            case {{ grade_column }}
                when 'D*' then 60
                when 'D' then 50
                when 'M' then 40
                when 'P' then 30
                else 0
            end
        else 0
    end
{% endmacro %}


{% macro get_ucas_points(grade_column, offering_type_id_column) %}
    {#-
    Returns UCAS tariff points based on grade and qualification type.
    Based on 2024-25 UCAS tariff.

    Args:
        grade_column: The column containing the grade
        offering_type_id_column: The column containing offering type ID

    Returns:
        INT64 UCAS points
    -#}
    case
        -- A-Level grades
        when {{ offering_type_id_column }} in (1, 2) then
            case {{ grade_column }}
                when 'A*' then 56
                when 'A' then 48
                when 'B' then 40
                when 'C' then 32
                when 'D' then 24
                when 'E' then 16
                else 0
            end
        -- BTEC Extended Certificate (equivalent to 1 A-Level)
        when {{ offering_type_id_column }} in (4) then
            case {{ grade_column }}
                when 'D*' then 56
                when 'D' then 48
                when 'M' then 32
                when 'P' then 16
                else 0
            end
        else 0
    end
{% endmacro %}
