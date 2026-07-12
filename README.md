# dbt Bookshop

A small, **run-verified** dbt project that models a fictional online **bookshop**, from three raw CSVs into tested, documented analytics tables. It's the companion code for the *"dbt from the ground up"* blog series — every model, test, snapshot, and macro the series builds, in one clonable project that gets a green `dbt build` out of the box.

It runs entirely on your laptop against [DuckDB](https://duckdb.org) — no cloud warehouse, no account, no bill.

## Prerequisites

- [`uv`](https://docs.astral.sh/uv/) (Python package/venv manager). That's it — `uv` fetches Python, dbt Core, and the DuckDB adapter for you. DuckDB itself ships inside the adapter, so there's no database server to install.

## Quickstart

```bash
# 1. Install dbt Core + the DuckDB adapter into a local venv
uv sync

# 2. Install dbt packages (dbt_utils)
uv run dbt deps

# 3. Load seeds, build models, and run tests — all in dependency order
uv run dbt build
```

A successful `dbt build` ends with:

```
Done. PASS=35 WARN=0 ERROR=0 SKIP=0 NO-OP=0 TOTAL=35
```

Verified against **dbt-core 1.11.12** and **dbt-duckdb 1.10.1** (the exact versions the blog series was written against).

> ### ⚠️ Use `dbt build`, not `dbt run`
> The raw data ships as CSV **seeds**, and only `dbt build` (or a separate `dbt seed`) loads them into DuckDB. Plain `dbt run` builds *models only*, so on a fresh clone it fails with:
> ```
> Catalog Error: Table with name raw_customers does not exist!
> ```
> That's expected — the seed tables just aren't there yet. If you want the `dbt run` loop the series teaches, run `uv run dbt seed` once first, then `dbt run` works.

### Querying the results

The build writes a DuckDB file, `bookshop.duckdb`, in the project root. Query it any way you like — for example with the bundled Python duckdb module:

```bash
uv run python -c "import duckdb; print(duckdb.connect('bookshop.duckdb').sql('select * from customers order by customer_id'))"
```

Or the DuckDB CLI:

```sql
-- duckdb bookshop.duckdb
select customer_id, first_name, plan, number_of_orders, lifetime_value
from customers
order by customer_id;
```

### Other useful commands

```bash
uv run dbt run                 # build models only
uv run dbt test                # run tests only
uv run dbt snapshot            # capture SCD2 history for customers
uv run dbt docs generate       # build the docs site + lineage graph
uv run dbt docs serve          # browse it on localhost
```

## What's in here

```
seeds/            raw_customers, raw_orders, raw_payments (the raw CSVs)
models/
  staging/        stg_customers, stg_orders, stg_payments (views; rename + cast + tests)
  intermediate/   int_order_payments (payments rolled up per order)
  marts/          orders, customers (tables), order_events (incremental)
snapshots/        customers_snapshot (SCD2 history on the `plan` column)
macros/           cents_to_dollars
tests/            assert_no_negative_payments (singular data test)
```

Highlights, mapped to the series:

- **`ref()` / the DAG** — staging → intermediate → marts, wired by `ref()`.
- **Seeds** — three raw CSVs (`raw_customers`, `raw_orders`, `raw_payments`) with a cancelled order, unpaid orders, and split payments so the models are non-trivial.
- **Materializations** — staging as views, marts as tables (set by folder in `dbt_project.yml`), plus an **incremental** `order_events` model.
- **Data tests** — `unique` / `not_null` on keys, `accepted_values`, `relationships` (referential integrity), and a singular `assert_no_negative_payments`.
- **Unit test** — `lifetime_value_sums_orders` pins the lifetime-value aggregation against fixed inputs.
- **Jinja & macros** — `cents_to_dollars` converts integer-cent amounts to dollars; `dbt_utils.generate_surrogate_key` builds a payment key.
- **Snapshots** — `customers_snapshot` records `plan` changes over time (Type-2 SCD).

## Connection

`profiles.yml` lives in the project root (dbt reads it from the working directory), targeting a local DuckDB file. Nothing external to configure.
