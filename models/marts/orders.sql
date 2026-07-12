with orders as (
    select * from {{ ref('stg_orders') }}
),

order_payments as (
    select * from {{ ref('int_order_payments') }}
)

select
    orders.order_id,
    orders.customer_id,
    orders.order_date,
    orders.status,
    coalesce(order_payments.amount, 0) as amount
from orders
left join order_payments
    on orders.order_id = order_payments.order_id
