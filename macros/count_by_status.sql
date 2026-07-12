{% macro count_by_status(status_column, statuses) %}
    {%- for status in statuses %}
    sum(case when {{ status_column }} = '{{ status }}' then 1 else 0 end) as {{ status }}_orders
    {%- if not loop.last %},{% endif -%}
    {%- endfor %}
{% endmacro %}
