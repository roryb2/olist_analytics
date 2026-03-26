with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2016-01-01' as date)",
        end_date="cast('2018-12-31' as date)"
    ) }}
),

orders as (
    select
        ordered_at::date as order_date,
        count(order_id)  as order_count,
        sum(total_payment_amount) as daily_revenue,
        avg(total_payment_amount) as avg_order_value
    from {{ ref('fct_orders') }}
    group by ordered_at::date
)

select
    date_spine.date_day,
    coalesce(orders.order_count, 0)    as order_count,
    coalesce(orders.daily_revenue, 0)  as daily_revenue,
    orders.avg_order_value             as avg_order_value
from date_spine
left join orders
    on date_spine.date_day = orders.order_date