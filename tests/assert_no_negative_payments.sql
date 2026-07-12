-- A singular data test: no payment amount should ever be negative.
-- Like every dbt test, it passes when it returns zero rows.
select
    payment_id,
    amount
from {{ ref('stg_payments') }}
where amount < 0
