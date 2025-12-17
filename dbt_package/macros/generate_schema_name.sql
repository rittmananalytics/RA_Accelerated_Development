{% macro generate_schema_name(custom_schema_name, node) -%}
    {#-
    Generates the schema (BigQuery dataset) name for models and seeds.

    Resulting dataset names:
    - No custom schema: analytics_rudgepark (target schema only)
    - With custom schema: analytics_rudgepark_<custom_schema>

    Examples:
    - marts (no custom schema): analytics_rudgepark
    - staging: analytics_rudgepark_staging
    - intermediate: analytics_rudgepark_integration
    - seeds: analytics_rudgepark_seed
    - raw_focus seeds: analytics_rudgepark_seed_raw_focus
    -#}

    {%- set default_schema = target.schema -%}

    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {{ default_schema }}_{{ custom_schema_name | trim }}
    {%- endif -%}

{%- endmacro %}
