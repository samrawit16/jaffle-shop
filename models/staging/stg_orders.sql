with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

renamed as (
    select
        id as order_id,
        customer_id,
        ordered_at,
        status
    from source
)

select * from renamed
