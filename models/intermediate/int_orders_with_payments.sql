-- Represents a summary of each order and their payments. 

with payments as (
    select
        order_id,
        SUM(payment_amount) as total_payment_amount,
        max(no_of_installments) as max_installments,
        count(distinct payment_method) as payment_method_count
    from {{ ref('stg_payments') }}
    group by order_id
),
primary_payment as (
    select
        order_id,
        payment_method,
        payment_amount,
        row_number() over (
            partition by order_id 
            order by payment_amount desc
        ) as rn
    from {{ ref('stg_payments') }}
),

primary_payment_method as (
    select order_id, payment_method
    from primary_payment
    where rn = 1
), 
orders as (
    select
        order_id,
        customer_id,
        order_status,
        ordered_at,
        approved_at,
        shipped_at,
        delivered_at,
        estimated_delivery_at
    from {{ ref('stg_orders') }}
)

select
    orders.order_id as order_id,
    orders.customer_id as customer_id,
    orders.order_status as order_status,
    orders.ordered_at,
    orders.approved_at,
    orders.shipped_at,
    orders.delivered_at,
    orders.estimated_delivery_at,
    payments.total_payment_amount as total_payment_amount,
    primary_payment_method.payment_method as primary_payment_method,
    payments.max_installments as max_installments,
    payments.payment_method_count as payment_method_count
from orders
inner join payments
on orders.order_id = payments.order_id
left join primary_payment_method
on payments.order_id = primary_payment_method.order_id

