-- Daily store health: revenue, refunds, order volume.
with orders as (
    select
        o.order_id,
        o.ordered_at,
        o.status,
        p.payment_method,
        p.amount
    from {{ ref('stg_orders') }} o
    left join {{ ref('stg_payments') }} p
        on o.order_id = p.order_id
),

classified as (
    select
        *,
        date(ordered_at) as order_date,
        case
            when amount < 0 then 'refund'
            when payment_method in ('credit_card', 'bank_transfer') then 'paid'
            else 'voucher'
        end as cash_type
    from orders
)

select
    order_date,
    status,
    sum(case when cash_type = 'paid' then amount else 0 end) as paid_amount,
    sum(case when cash_type = 'refund' then abs(amount) else 0 end) as refund_amount,
    sum(case when cash_type = 'voucher' then amount else 0 end) as voucher_amount,
    sum(amount) as total_amount,
    count(distinct order_id) as order_count
from classified
group by order_date, status
