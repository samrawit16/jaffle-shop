# Jaffle Shop Analytics

Analytics engineering project on the dbt jaffle shop sample data, built to answer
real business questions a sandwich chain actually faces — not just the tutorial.

## The problem
The COO of a growing sandwich chain asks three questions the default tutorial models
cannot answer:
1. Which customers are at risk of churning, before they stop buying?
2. How much money do refunds cost us, and is it concentrated in certain stores?
3. Which locations are healthy and which need intervention?

## Structure
- `models/staging` — clean, typed, tested views over raw data
- `models/marts/finance` — daily store health, refund exposure
- `models/marts/customers` — RFM-style churn risk segmentation
- `tests` — custom singular tests, including a finance reconciliation test

## Run locally
dbt deps && dbt build
dbt docs generate && dbt docs serve
