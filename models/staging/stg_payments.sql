with source as (
    select * from {{ ref('raw_payments') }}
)

select
    id                                     as payment_id,
    {{ dbt_utils.generate_surrogate_key(['id']) }} as payment_key,
    order_id,
    payment_method,
    -- amounts arrive as integer cents; store dollars
    {{ cents_to_dollars('amount') }}       as amount
from source
