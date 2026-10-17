-- Refund exposure by payment method and order status.
select
    o.status,
    p.payment_method,
    sum(abs(p.amount)) as total_refunded,
    count(*) as refund_events
from {{ ref('stg_payments') }} p
left join {{ ref('stg_orders') }} o
    on p.order_id = o.order_id
where p.amount < 0
group by o.status, p.payment_method
