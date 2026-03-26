-- models/staging/stg_sellers.sql
-- Represents individual sellers on the Olist marketplace

with source as (
    select * from {{ ref('olist_sellers_dataset') }}
),

renamed as (
    select
        seller_id,
        seller_zip_code_prefix  as zip_code,
        seller_city             as city,
        seller_state            as state
    from source
)

select * from renamed