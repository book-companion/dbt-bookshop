# dbt Bookshop

[![dbt build](https://github.com/engineers-musings-companion/dbt-bookshop/actions/workflows/build.yml/badge.svg)](https://github.com/engineers-musings-companion/dbt-bookshop/actions/workflows/build.yml)

> **Matching the book.** The tag **`v1.0-book`** is the exact state of this
> project as published in *"dbt: SQL Promoted to Software"*. `main` may move
> ahead of the book; if you want what the chapters describe, check out the tag:
>
> ```bash
> git clone --branch v1.0-book https://github.com/engineers-musings-companion/dbt-bookshop.git
> ```

A small, **run-verified** dbt project that models a fictional online **bookshop**, from three raw CSVs into tested, documented analytics tables. It's the companion code for the *"dbt: SQL Promoted to Software"* book — every model, test, snapshot, and macro the book builds, in one clonable project that gets a green `dbt build` out of the box.

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
Done. PASS=39 WARN=0 ERROR=0 SKIP=0 NO-OP=1 TOTAL=40
```

Verified against **dbt-core 1.11.12** and **dbt-duckdb 1.10.1** (the exact versions the book was written against).

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

### Known-good commands

Every command below runs green against this repo at `v1.0-book`. They are grouped
by the chapter that introduces them, so you can jump straight to whatever you are
reading. Chapters are named rather than numbered — numbering can shift between
printings, titles do not.

| Command | What it does | Chapter |
|---|---|---|
| `uv run dbt build` | Seeds, models, snapshots, and tests in dependency order — **PASS=39** | *Your First Project* |
| `uv run dbt run` | Models only (needs `dbt seed` first on a fresh clone) | *Models and the DAG* |
| `uv run dbt test` | Data tests and unit tests only | *Testing Your Data* |
| `uv run dbt seed` | Loads the three raw CSVs into DuckDB | *Sources and Seeds* |
| `uv run dbt snapshot` | Captures SCD2 history for `customers` | *Snapshots* |
| `uv run dbt run --select stg_orders+` | The selector syntax, on a real graph | *Node Selection and Build* |
| `uv run dbt build --select state:modified+ --state ./target` | State-aware, CI-style run | *Deployment, CI, and Orchestration* |
| `uv run dbt docs generate && uv run dbt docs serve` | Builds and browses the lineage graph | *Docs and Lineage* |
| `uv run dbt parse` | Writes `target/manifest.json` without touching the warehouse | *Docs and Lineage* |
| `uv run mf list metrics` | Lists the semantic layer's metrics | *The Semantic Layer and Metrics* |
| `uv run mf query --metrics revenue --group-by metric_time` | Queries a metric through MetricFlow | *The Semantic Layer and Metrics* |

## What's in here

```
seeds/            raw_customers, raw_orders, raw_payments (the raw CSVs)
models/
  staging/        stg_customers, stg_orders, stg_payments (views; rename + cast + tests)
  intermediate/   int_order_payments (payments rolled up per order)
  marts/          orders, customers, orders_by_customer (tables), order_events (incremental)
snapshots/        customers_snapshot (SCD2 history on the `plan` column)
macros/           cents_to_dollars, count_by_status (a for-loop pivot)
tests/            assert_no_negative_payments (singular)
tests/generic/    not_negative (custom generic test)
```

Highlights, mapped to the book:

- **`ref()` / the DAG** — staging → intermediate → marts, wired by `ref()`.
- **Seeds** — three raw CSVs (`raw_customers`, `raw_orders`, `raw_payments`) with a cancelled order, unpaid orders, and split payments so the models are non-trivial.
- **Materializations** — staging as views, marts as tables (set by folder in `dbt_project.yml`), plus an **incremental** `order_events` model (with an explicit `incremental_strategy` and `on_schema_change`).
- **Data tests** — `unique` / `not_null` on keys, `accepted_values`, `relationships` (referential integrity), a singular `assert_no_negative_payments`, and a custom **generic** test `not_negative`.
- **Unit tests** — `lifetime_value_sums_orders` pins the aggregation against fixed inputs; `lifetime_value_of_customer_with_no_orders` covers the zero-orders edge case.
- **Jinja & macros** — `cents_to_dollars` converts integer-cent amounts to dollars; `count_by_status` is a `{% for %}` pivot that writes one order-count column per status; `dbt_utils.generate_surrogate_key` builds a payment key.
- **Snapshots** — `customers_snapshot` records `plan` changes over time (Type-2 SCD).

## Connection

`profiles.yml` lives in the project root (dbt reads it from the working directory), targeting a local DuckDB file. Nothing external to configure.
