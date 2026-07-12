{% set order_statuses = ['placed', 'shipped', 'completed', 'returned'] %}

select
    customer_id,
    count(*) as total_orders,
    {{ count_by_status('status', order_statuses) }}
from {{ ref('stg_orders') }}
group by customer_id
