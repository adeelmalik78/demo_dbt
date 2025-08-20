# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository demonstrates the integration between Liquibase (database change management) and dbt (data transformation) on Snowflake. Liquibase manages database schema changes while dbt handles data modeling and transformations in the AMDB database.

## Architecture

- **Database**: Snowflake (AMDB database)
- **Source Schema**: AMDB.PUBLIC (raw data tables: customers, orders)
- **Target Schema**: AMDB.DBT (transformed models and views)
- **Authentication**: Public/private key authentication for Snowflake
- **Coordination**: Liquibase Flow files orchestrate both schema changes and dbt transformations

### Key Components

1. **dbt Models** (`models/`):
   - `customer_order_summary.sql`: Incremental model with customer analytics and segmentation
   - `orders_view.sql`: Simple view classifying orders as high_value (>$1000) or regular
   - `schema.yml`: Model and source definitions with tests

2. **Liquibase Setup** (`liquibase/`):
   - `changelog.main.xml`: Main changelog that includes all changesets
   - `liquibase.properties`: Database connection and authentication settings
   - `profiles.yml`: dbt profile configuration for Snowflake
   - Flow files for automated workflows (see Commands section)

## Essential Commands

### Liquibase Commands

```bash
# Navigate to liquibase directory first
cd liquibase

# Main deployment flow - creates base objects and runs dbt
liquibase flow

# Incremental changes flow - detects schema changes and updates dbt models
liquibase flow --flow-file=liquibase.incremental.yaml

# Reset environment for next demo
liquibase flow --flow-file=liquibase.reset.yaml

# Basic Liquibase operations
liquibase status
liquibase update
liquibase rollback-count 1
liquibase connect
```

### dbt Commands

```bash
# Build all models (run + test)
dbt build --profile liquibase --project-dir . --full-refresh

# Run specific models
dbt build --profile liquibase --project-dir . --select "customer_order_summary orders_view"

# Test models
dbt test --profile liquibase --project-dir .

# Generate documentation
dbt docs generate --profile liquibase --project-dir .
dbt docs serve --profile liquibase --project-dir .
```

## Configuration Files

### Required Updates Before Running

1. **liquibase/liquibase.properties**:
   - Update Snowflake URL, warehouse, database, user
   - Set correct path to private key file
   - Update private key passphrase

2. **liquibase/profiles.yml**:
   - Update Snowflake connection details
   - Set correct private key path and passphrase

## Development Workflow

### Standard Demo Flow

1. Create base database objects: `liquibase flow`
2. Make schema changes (e.g., add email column to customers table)
3. Generate incremental changelog: `liquibase flow --flow-file=liquibase.incremental.yaml`
4. Update dbt model files to include new columns
5. Deploy changes: `liquibase flow`

### Schema Change Pattern

When adding new columns:

1. **Database Change**: Use ALTER TABLE or let Liquibase detect changes
2. **dbt Model Update**: Add new columns to relevant CTEs in SQL models
   - Update `customers` CTE in `customer_order_summary.sql`
   - Update `final` CTE to include new columns in output
3. **Schema Definition**: Update `models/schema.yml` with new column definitions and tests

### Drift Detection

The flow file includes drift detection capabilities:
- `Drift_Detection` stage compares database state with snapshots
- Generates HTML reports in `reports/` directory
- Outputs diff JSON for programmatic analysis

## File Structure Notes

- **Changesets**: Stored in `liquibase/Changesets/` and included via changelog
- **Reports**: Generated in `liquibase/reports/` (HTML format)
- **Snapshots**: Database state snapshots in `liquibase/snapshots/` (JSON format)
- **Scripts**: Python utilities in `liquibase/Scripts/` for advanced operations
- **dbt Artifacts**: Generated in `target/` directory (compiled SQL, docs, etc.)

## Integration Points

- Flow files coordinate Liquibase and dbt execution
- Shared Snowflake connection configuration
- dbt models reference Liquibase-managed source tables via `{{ source('prod', 'table_name') }}`
- Incremental models use `modified_at` timestamps for change detection

## Testing

- dbt tests are defined in `models/schema.yml`
- Tests include uniqueness, not null constraints, and referential integrity
- Run tests with: `dbt test --profile liquibase --project-dir .`