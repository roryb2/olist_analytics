-- Description: Customer Order items and it's details

with source as (
    select * from {{ref('olist_order_items_dataset')}}
),

renamed as (
    select
        {{ dbt_utils.generate_surrogate_key(['order_id', 'order_item_id']) }} as order_item_sk,
        order_id,
        order_item_id       as item_id,
        product_id,
        seller_id,
        shipping_limit_date as shipping_limit_at,
        price               as item_price,
        freight_value       as freight_amount
    from source
)

select * from renamed