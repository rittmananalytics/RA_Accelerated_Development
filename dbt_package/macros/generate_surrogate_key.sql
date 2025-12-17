{% macro generate_surrogate_key(field_list) %}
    {#-
    Generates a surrogate key from a list of fields using SHA256 hash.
    This is a wrapper around dbt_utils.generate_surrogate_key for consistency.

    Args:
        field_list: List of field names to include in the key

    Returns:
        INT64 surrogate key
    -#}
    {{ dbt_utils.generate_surrogate_key(field_list) }}
{% endmacro %}


{% macro generate_int_surrogate_key(field_list) %}
    {#-
    Generates an integer surrogate key from a list of fields.
    Uses farm_fingerprint for a deterministic INT64 hash.

    Args:
        field_list: List of field names to include in the key

    Returns:
        INT64 surrogate key
    -#}
    farm_fingerprint(
        concat(
            {% for field in field_list %}
                coalesce(cast({{ field }} as string), '_dbt_null_')
                {% if not loop.last %}, '|', {% endif %}
            {% endfor %}
        )
    )
{% endmacro %}
