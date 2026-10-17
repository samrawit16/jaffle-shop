-- Reconciliation: the 'paid' bucket in the daily store health mart must
-- equal the sum of positive credit_card + bank_transfer payments in staging.
-- If this fails, a payment was misclassified in the finance pipeline.
with payments_by_date as (
    select
        date(o.ordered_at) as order_date,
        o.status,
        sum(p.amount) as expected_paid
    from {{ ref('stg_payments') }} p
    left join {{ ref('stg_orders') }} o on p.order_id = o.order_id
    where p.payment_method in ('credit_card', 'bank_transfer')
      and p.amount >= 0
    group by 1, 2
),

mart as (
    select order_date, status, paid_amount
    from {{ ref('fct_daily_store_health') }}
)

select m.order_date, m.status, m.paid_amount, p.expected_paid
from mart m
left join payments_by_date p
    on m.order_date = p.order_date and m.status = p.status
where m.paid_amount != coalesce(p.expected_paid, 0)
   or coalesce(p.expected_paid, 0) != 0 and m.order_date is null
