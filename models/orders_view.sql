{{ config(materialized='view') }}

select
    order_id,
    customer_id,
    total_amount,
    order_date,
    modified_at,
    case when total_amount > 1000 then 'high_value' else 'regular' end as order_value_type
    -- datediff('day', order_date, current_date()) as order_age_days
from {{ source('prod', 'orders') }}