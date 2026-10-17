{% snapshot snap_customers %}

{{
    config(
      target_schema='jaffle_shop_snapshots',
      unique_key='customer_id',
      strategy='check',
      check_cols=['status'],
      invalidate_hard_deletes=True
    )
}}

-- Derive each customer's current business status from their orders.
with latest_order as (
    select
        customer_id,
        max(ordered_at) as last_order_at
    from {{ ref('stg_orders') }}
    group by customer_id
)

select
    c.customer_id,
    case
        when o.last_order_at is null then 'never_activated'
        else 'active'
    end as status
from {{ ref('stg_customers') }} c
left join latest_order o using (customer_id)

{% endsnapshot %}
