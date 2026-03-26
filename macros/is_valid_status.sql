{% macro is_valid_status(column_name, list_statuses) %}
    (case
        when {{ column_name }} in ({% for status in list_statuses %}
            '{{ status }}'{% if not loop.last %},{% endif %}{% endfor %}
        ) then true
        else false
    end)
{% endmacro %}