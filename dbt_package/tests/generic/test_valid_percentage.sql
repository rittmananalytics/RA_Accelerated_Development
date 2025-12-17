{% test valid_percentage(model, column_name) %}
{#-
Tests that a percentage column contains valid values between 0 and 100.
-#}

select
    {{ column_name }}
from {{ model }}
where {{ column_name }} is not null
  and ({{ column_name }} < 0 or {{ column_name }} > 100)

{% endtest %}
