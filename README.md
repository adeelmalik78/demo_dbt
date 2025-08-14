# Using the starter project


## Project Overview:
- A demonstration showing how Liquibase (database change management) integrates with DBT (data transformation) on Snowflake
- Liquibase manages database schema changes while DBT handles data modeling and transformations

##  Key Components:
1. DBT Models (models/):
    - customer_order_summary.sql - Customer analytics with order metrics and segmentation
    - orders_view.sql - Order classification view (high_value vs regular)
    - Source tables: customers and orders from AMDB.PUBLIC schema
2. Liquibase Setup (liquibase/):
    - Database change management with XML changelogs
    - Flow files for automated deployment workflows
    - Scripts for incremental updates and seeding data
    - Authentication via public/private keys for Snowflake

##  Demo Flow:
- Creates base database objects via Liquibase
- Runs DBT models to transform data into analytics tables
- Shows incremental schema changes (adding email column)
- Demonstrates coordinated updates between database schema and DBT models

The project targets the AMDB database with PUBLIC schema for raw data and DBT schema for transformed models.


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [dbt community](https://getdbt.com/community) to learn from other analytics engineers
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
