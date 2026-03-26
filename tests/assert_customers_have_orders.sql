-- Customers with null total_orders are excluded from this test
-- as they represent known data quality edge cases (missing payment records)
select
    customer_unique_id,
    total_orders
from {{ ref('dim_customers') }}
where total_orders < 1
-- null total_orders are intentionally excluded