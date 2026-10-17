-- RFM-style customer segmentation for churn risk.
with order_payments as (
    select
        o.order_id,
        o.customer_id,
        o.ordered_at,
        o.status,
        sum(p.amount) as total_amount
    from {{ ref('stg_orders') }} o
    left join {{ ref('stg_payments') }} p on o.order_id = p.order_id
    group by 1, 2, 3, 4
),

customer_orders as (
    select
        customer_id,
        min(ordered_at) as first_order,
        max(ordered_at) as most_recent_order,
        count(*) as number_of_orders,
        countif(status = 'completed') as completed_orders,
        sum(case when status = 'completed' then total_amount else 0 end) as lifetime_value,
        date_diff(current_date(), cast(max(case when status = 'completed' then ordered_at end) as date), day) as days_since_last_order
    from order_payments
    group by 1
)

select
    c.customer_id,
    c.first_name,
    c.last_name,
    co.first_order,
    co.most_recent_order,
    co.number_of_orders,
    co.completed_orders,
    co.lifetime_value,
    co.days_since_last_order,
    case
        when co.completed_orders is null or co.completed_orders = 0 then 'never_activated'
        when co.days_since_last_order <= 30 then 'healthy'
        when co.days_since_last_order <= 90 then 'at_risk'
        else 'churned'
    end as churn_segment
from {{ ref('stg_customers') }} c
left join customer_orders co on c.customer_id = co.customer_id
