-- Finance mart must reconcile against payments.
-- Fails if any payment was misclassified in the finance pipeline.
select
    sum(paid_amount) as total_paid,
    sum(amount) as total_all
from {{ ref('fct_daily_store_health') }}
having sum(paid_amount) != sum(amount)
