{% macro safe_cast_percentage(column_name) %}
    {#-
    Safely casts a percentage string to numeric, handling:
    - Percentage signs (%)
    - Spaces
    - Empty strings
    - NULL values

    Args:
        column_name: The name of the column to cast

    Returns:
        NUMERIC(5,2) or NULL
    -#}
    safe_cast(
        nullif(
            trim(
                regexp_replace(
                    {{ column_name }},
                    r'[%\s]',
                    ''
                )
            ),
            ''
        ) as numeric
    )
{% endmacro %}
