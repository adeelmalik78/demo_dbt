-- liquibase formatted sql

-- changeset adeelmalik:1755537574682-1 splitStatements:false
CREATE TABLE CUSTOMER_ORDER_SUMMARY (CUSTOMER_ID VARCHAR(50), CUSTOMER_NAME VARCHAR(255), ORDER_COUNT NUMBER(18), TOTAL_SPENT NUMBER(24, 2), LAST_ORDER_DATE date, CUSTOMER_TYPE VARCHAR(10), MOST_RECENT_ORDER_ID VARCHAR(50));

-- changeset adeelmalik:1755537574682-2 splitStatements:false
CREATE VIEW ORDERS_VIEW AS (
    

select
    order_id,
    customer_id,
    total_amount,
    order_date,
    modified_at,
    case when total_amount > 1000 then 'high_value' else 'regular' end as order_value_type
from AMDB.PUBLIC.orders
  )
/* {"app": "dbt", "dbt_version": "1.10.8", "profile_name": "liquibase", "target_name": "dev", "node_id": "model.liquibase.orders_view"} */;

