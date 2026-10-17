with source as (
    select * from {{ source('raw', 'raw_payments') }}
),

renamed as (
    select
        id as payment_id,
        order_id,
        payment_method,
        -- in the jaffle sample data, non-card amounts are stored negative;
        -- normalize so all amounts are positive and sign logic lives in marts
        abs(amount) as amount
    from source
)

select * from renamed
