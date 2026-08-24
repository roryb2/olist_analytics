# Olist E-Commerce Analytics (dbt)

A dbt project that transforms the [Olist Brazilian E-Commerce public dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) into tested, documented staging, intermediate, and mart-layer models on BigQuery, covering order fulfillment, payments, revenue trending, and customer value.

## Architecture

**Staging** (`models/staging`): seven models cleaning and renaming raw seed data one-to-one with source tables — orders, customers, order items, payments, products, reviews, and sellers.

**Intermediate** (`models/intermediate`): `int_orders_with_payments` joins orders to their payment records, resolving each order down to a total payment amount and primary payment method.

**Marts** (`models/marts`), organized by business domain:
- **Finance** — `fct_orders`: an incremental order fact table with delivery time and order-status flags. `fct_daily_revenue`: daily revenue trending, zero-filled for days with no orders using `dbt_utils.date_spine`.
- **Marketing** — `dim_customers`: customer-level total spend, average order value, and a repeat-customer flag — the core inputs to a customer lifetime value analysis.

## Engineering notes

- `fct_orders` is built as an **incremental model** (`unique_key`, `on_schema_change='sync_all_columns'`), not a full rebuild on every run.
- Custom macros (`date_diff_days`, `is_valid_status`, `cents_to_dollars`) are **warehouse-portable**, branching on `target.type` to support both BigQuery and DuckDB.
- 45+ automated data tests across staging, intermediate, and mart models (`unique`, `not_null`, `relationships`, `accepted_values`), plus two custom business-logic tests: `assert_customers_have_orders` and `assert_delivery_time_non_negative`.
- Column-level documentation notes real data quality issues in the source data (for example, `dim_customers.total_spend` can be null where a customer has no valid payment record) rather than glossing over them.
- A small Python/pandas script (`preclean.py`) handles a source-data cleanup step (malformed newline characters in review text) before the affected seed is loaded.

## Tech stack

dbt · BigQuery · [dbt_utils](https://github.com/dbt-labs/dbt-utils) · Python (pandas)

## Data source

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle), loaded as dbt seeds.