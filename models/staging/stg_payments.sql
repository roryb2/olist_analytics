-- Description: Customer payments

with source as (
    select * from {{ ref('olist_order_payments_dataset') }}
),

renamed as (
    select
        order_id,
        payment_sequential   as payment_sequence,
        payment_type         as payment_method,
        payment_installments as no_of_installments,
        payment_value        as payment_amount
    from source
)

select * from renamed