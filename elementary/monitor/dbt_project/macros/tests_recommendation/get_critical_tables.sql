{% macro get_critical_tables(
    depends_on_count=none,
    dependant_on_count=none,
    exposure_count=none,
    critical_name_like_patterns=none,
    table_types=none
) %}
    {# TODO: Decide if those should be OR or AND operators. #}
    {% set query %}
        select resource_name, source_name, timestamp_columns
        from {{ ref("table_timestamp_columns") }}
        where 1=1

        {% if depends_on_count %}
            and depends_on_count >= {{ depends_on_count }}
        {% endif %}

        {% if dependant_on_count %}
            and dependant_on_count >= {{ dependant_on_count }}
        {% endif %}

        {% if exposure_count %}
            and exposure_count >= {{ exposure_count }}
        {% endif %}

        {% if critical_name_like_patterns %}
            {% for name_like_pattern in critical_name_like_patterns %}
                and resource_name like '{{ name_like_pattern }}'
            {% endfor %}
        {% endif %}

        {% if table_types %}
            and table_type in ('{{ table_types | join("','") }}')
        {% endif %}
    {% endset %}

    {% set result = elementary.run_query(query) %}
    {% do return(elementary.agate_to_dicts(result)) %}
{% endmacro %}
