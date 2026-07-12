{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns'
    )
}}

-- An append-only event log of orders. On the first run dbt builds the whole
-- table; on later runs the is_incremental() guard keeps only rows newer than
-- what we already have.
select
    order_id,
    customer_id,
    order_date,
    status
from {{ ref('stg_orders') }}

{% if is_incremental() %}
where order_date > (select max(order_date) from {{ this }})
{% endif %}
