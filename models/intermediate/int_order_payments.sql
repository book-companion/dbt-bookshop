-- Roll payments up to one row per order.
with payments as (
    select * from {{ ref('stg_payments') }}
)

select
    order_id,
    sum(amount) as amount
from payments
group by 1
