with customers as (
    select * from {{ ref('stg_customers') }}
),

customer_orders as (
    select
        customer_id,
        count(order_id)  as number_of_orders,
        sum(amount)      as lifetime_value,
        min(order_date)  as first_order_date,
        max(order_date)  as most_recent_order_date
    from {{ ref('orders') }}
    group by 1
)

select
    customers.customer_id,
    customers.first_name,
    customers.plan,
    coalesce(customer_orders.number_of_orders, 0) as number_of_orders,
    coalesce(customer_orders.lifetime_value, 0)   as lifetime_value,
    customer_orders.first_order_date,
    customer_orders.most_recent_order_date
from customers
left join customer_orders
    on customers.customer_id = customer_orders.customer_id
