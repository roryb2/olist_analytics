{{
    config(
        materialized='table'
    )
}}

with latest_orders as (
    select
        c.customer_unique_id,
        c.customer_id,
        c.city,
        c.state,
        row_number() over (
            partition by c.customer_unique_id
            order by o.ordered_at desc
        ) as rn
    from {{ ref('stg_customers') }} c
    left join {{ ref('fct_orders') }} o
        on c.customer_id = o.customer_id
),

latest_address as (
    select customer_unique_id, customer_id, city, state
    from latest_orders
    where rn = 1
),
orders as(
    select
        c.customer_unique_id as customer_unique_id,
        min(ordered_at) as first_order_at,
        max(ordered_at) as most_recent_order_at,
        count(order_id) as total_orders,
        sum(total_payment_amount) as total_spend,
        avg(total_payment_amount) as avg_order_value
    from {{ ref('fct_orders') }} o
    left join {{ ref('stg_customers') }} c
    on o.customer_id = c.customer_id
    group by c.customer_unique_id
)

select
    latest_address.customer_unique_id as customer_unique_id,
    latest_address.city as city,
    latest_address.state as state,
    orders.first_order_at as first_order_at,
    orders.most_recent_order_at as most_recent_order_at,
    orders.total_orders as total_orders,
    orders.total_spend as total_spend,
    orders.avg_order_value as avg_order_value,
    case
        when coalesce(orders.total_orders,0) > 1 then true
        else false
    end as is_repeat_customer
from latest_address
left join orders
on latest_address.customer_unique_id = orders.customer_unique_id

