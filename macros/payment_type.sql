{% macro paid_method(method) %}
    {{ return(method in ['credit_card', 'bank_transfer']) }}
{% endmacro %}
