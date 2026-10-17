# Jaffle Shop Analytics — dbt + BigQuery

![dbt](https://img.shields.io/badge/dbt-1.12-orange)
![BigQuery](https://img.shields.io/badge/warehouse-BigQuery-blue)
![tests](https://img.shields.io/badge/tests-15%20passing-brightgreen)

A production-style dbt project on BigQuery that answers two real questions a
jaffle shop COO would actually ask:

1. **Where is money leaking?** — `fct_daily_store_health` tracks daily revenue,
   refunds and voucher usage per order status; `agg_refund_exposure` shows
   which payment methods concentrate refund cost.
2. **Which customers are we about to lose?** — `dim_customers` segments every
   customer (healthy / at_risk / churned / never_activated) using RFM-style
   recency, frequency and lifetime value.

## Business impact (current dataset)

- **$167,200** collected across **99 orders** (all paid orders fully settled).
- **$0 refunded** — but the pipeline is built to surface refund exposure the
  moment it appears, and a reconciliation test guards the "paid" bucket
  against misclassification.
- **Customer base in trouble:** of 100 customers, **52 never activated** and
  **48 are churned** — zero "healthy" customers in this window, with
  **$110,300** of lifetime value concentrated in churned accounts. The
  segmentation is designed to flag exactly this pattern for the growth team.

## Structure

- `staging/` — light-touch views: rename, cast, one source of truth for raw tables
- `marts/finance/` — daily store health, refund exposure
- `marts/customers/` — customer dimension with churn segments
- `tests/` — custom reconciliation test asserting the finance mart ties out to staging payments
- `docs/key_queries.sql` — the executive-summary queries behind the numbers above

## Tests

15 tests: not_null, unique and accepted_values on staging keys, plus a custom
singular test (`assert_finance_mart_reconciles`) that fails if the mart's
"paid" bucket ever disagrees with the payment source data.

Run: `dbt seed --full-refresh && dbt build --exclude resource_type:seed`

## Notable debugging stories

- **404-as-data** — my first seed download fetched GitHub's 404 HTML page
  instead of CSVs, so seed tables loaded with HTML as column names. Diagnosed
  by querying `INFORMATION_SCHEMA` and spotting a literal `404: Not Found`
  column. Fixed by re-downloading the correct raw_*.csv files.
- **dbt schema prefixing** — the target schema `raw` became `jaffle_shop_raw`
  because dbt prefixes schemas; `sources.yml` had to match exactly.
- **Seed/source race** — sources and seeds are separate DAG nodes, so tests
  could query a seed mid-load. Solved by running seeds and the build as
  separate CI steps.
- **YAML placement** — `sources.yml` in the project root was invisible to
  dbt; source declarations must live under `models/`.


## Snapshots (SCD Type 2)

`snapshots/snap_customers.sql` tracks customer status history with a check
strategy on `status` (`unique_key=customer_id`, hard deletes invalidated).
It derives status from order data, not the raw table. Note: BigQuery's free
tier blocks DML, so running the snapshot requires a billed project — the
code is compile-validated here.
