{{
    config(
        materialized='incremental',
        unique_key='order_id',
        on_schema_change='sync_all_columns'
    )
}}

with owp as (
    select
        order_id,
        customer_id,
        order_status,
        ordered_at,
        delivered_at,
        total_payment_amount,
        primary_payment_method
    from {{ ref('int_orders_with_payments') }}

    {% if is_incremental() %}
    where ordered_at > (select max(ordered_at) from {{ this }})
    {% endif %}
),
order_items as (
    select
        order_id,
        count(item_id) as order_item_count,
        sum(freight_amount) as total_freight_amount
        from {{ ref('stg_order_items') }}
        group by order_id
)

select 
    owp.*,
    order_items.order_item_count as order_item_count,
    order_items.total_freight_amount as total_freight_amount,
    DATEDIFF('day', owp.ordered_at, owp.delivered_at) as delivery_time_days,
    case
        when owp.order_status = 'delivered' then true
        else false
    end as is_delivered,
    {{ is_valid_status('order_status', ['delivered', 'shipped', 'canceled', 
   'unavailable', 'invoiced', 'processing', 'approved', 'created']) }} 
    as is_valid_status
from owp
left join order_items
on owp.order_id = order_items.order_id