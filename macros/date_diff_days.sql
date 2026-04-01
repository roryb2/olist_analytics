{% macro date_diff_days(start_date, end_date) %}
    {% if target.type == 'bigquery' %}
        date_diff(cast({{ end_date }} as date), cast({{ start_date }} as date), day)
    {% elif target.type == 'duckdb' %}
        datediff('day', {{ start_date }}, {{ end_date }})
    {% else %}
        datediff('day', {{ start_date }}, {{ end_date }})
    {% endif %}
{% endmacro %}