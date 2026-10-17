# Jaffle Shop Analytics — dbt + BigQuery

A production-style dbt project on BigQuery that answers two real questions
a jaffle shop COO would actually ask:

1. **Where is money leaking?** — `fct_daily_store_health` tracks daily revenue,
   refunds and voucher usage per order status; `agg_refund_exposure` shows
   which payment methods concentrate refund cost.
2. **Which customers are we about to lose?** — `dim_customers` segments every
   customer (healthy / at_risk / churned / never_activated) using RFM-style
   recency, frequency and lifetime value.

## Structure

- `staging/` — light-touch views: rename, cast, and one source of truth for raw tables
- `marts/finance/` — daily store health, refund exposure
- `marts/customers/` — customer dimension with churn segments
- `tests/` — a custom reconciliation test asserting the finance mart ties out to staging payments

## Tests

15 tests: not_null, unique and accepted_values on staging keys, plus a custom
singular test (`assert_finance_mart_reconciles`) that fails if the mart's
"paid" bucket ever disagrees with the payment source data.

Run: `dbt seed --full-refresh && dbt build --exclude resource_type:seed`

## Notable debugging stories

- **Source schema mismatch** — the raw orders table uses `user_id`/`order_date`,
  not `customer_id`/`ordered_at`; staging renames once, downstream never sees it.
- **Seed/source race** — because sources and seeds are separate DAG nodes,
  tests could query a seed mid-load. Solved by running seeds and build as
  separate steps in CI.
- **dbt schema naming** — dbt prefixes target schema names
  (`raw` became `jaffle_shop_raw`), which sources must match exactly.
