--liquibase formatted sql

--changeset JBennett:create_customers_table
CREATE TABLE PUBLIC.customers (
    customer_id     VARCHAR(50)   NOT NULL,
    customer_name   VARCHAR(255),
    signup_date     DATE,
    country_code    CHAR(2),
    is_active       BOOLEAN,
    PRIMARY KEY (customer_id)
);
--rollback DROP TABLE PUBLIC.customers;

--changeset JBennett:seed_customers
INSERT INTO PUBLIC.customers (customer_id, customer_name, signup_date, country_code, is_active) VALUES
  (1, 'Alice Smith', DATE '2023-09-15', 'US', TRUE),
  (2, 'Bob Johnson', DATE '2024-03-02', 'CA', TRUE),
  (3, 'Carlos Díaz', DATE '2022-11-05', 'MX', FALSE),
  (4, 'Dana Lee', DATE '2024-06-01', 'US', TRUE);
--rollback DELETE FROM PUBLIC.customers WHERE customer_id IN (1, 2, 3, 4);

--changeset JBennett:create_orders_table
CREATE TABLE PUBLIC.orders (
    order_id       VARCHAR(50)   NOT NULL,
    customer_id    VARCHAR(50)   NOT NULL,
    total_amount   NUMERIC(12, 2),
    order_date     DATE,
    modified_at    TIMESTAMP,
    PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES PUBLIC.customers (customer_id)
);
--rollback DROP TABLE PUBLIC.orders;

--changeset JBennett:seed_orders
INSERT INTO PUBLIC.orders (order_id, customer_id, total_amount, order_date, modified_at) VALUES
  (101, 1, 100.00, DATE '2024-01-15', DATE '2024-01-16'),
  (102, 1, 250.00, DATE '2024-05-10', DATE '2024-05-11'),
  (103, 2, 800.00, DATE '2024-02-22', DATE '2024-02-23'),
  (104, 3, 50.00, DATE '2023-12-01', DATE '2023-12-02'),
  (105, 4, 1200.00, DATE '2024-06-20', DATE '2024-06-21');
--rollback DELETE FROM PUBLIC.orders WHERE order_id IN (101, 102, 103, 104, 105);