-- Executive summary queries (run with: dbt show --inline "$(cat docs/key_queries.sql)")

-- 1. Refund exposure by order status and payment method
-- select status, payment_method, total_refunded, refund_events
-- from jaffle_shop_finance.agg_refund_exposure order by total_refunded desc;

-- 2. Customer churn segmentation
-- select churn_segment, count(*) as customers, round(coalesce(sum(lifetime_value),0),2) as ltv
-- from jaffle_shop_customers.dim_customers group by 1 order by 2 desc;

-- 3. Total collected revenue
-- select sum(amount) as total_paid, count(distinct order_id) as orders
-- from jaffle_shop.stg_payments p join jaffle_shop.stg_orders o using (order_id);
