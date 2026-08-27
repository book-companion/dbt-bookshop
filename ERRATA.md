# Errata — *dbt: SQL Promoted to Software*

Corrections and updates for the first edition (August 2026).

This file lives in the companion repository rather than in the book, so it can
be corrected the day a mistake is found instead of waiting for the next edition.
If you are reading a downloaded copy, check here for anything that has changed
since.

**Found something wrong?** Open an issue on this repository. Please include the
chapter, the passage, what you ran, and what you saw — the more reproducible the
report, the faster it can be confirmed and listed here.

---

## Confirmed corrections

*None reported yet for the first edition.*

When entries appear, each will name the chapter, quote the text as printed, give
the correction, and date it — so a reader can tell at a glance whether their copy
predates the fix.

---

## Versions this edition was verified against

The book pins its toolchain deliberately. These are the versions its examples
were **run** on, not a claim about what is current:

| Component | Version |
| --- | --- |
| dbt Core | 1.11.12 |
| dbt-duckdb | 1.10.1 |
| DuckDB (bundled in the adapter) | 1.5.4 |
| dbt-metricflow | 0.14.0 |
| MetricFlow | 0.212.0 |
| dbt_utils | 1.4.1 |

Newer patch releases will not usually change anything the book teaches. Where a
newer release *does* change documented behaviour, it will be noted above.

## Matching your copy to this repository

The tag **`v1.0-book`** is the exact project state the first edition describes:

```bash
git clone --branch v1.0-book https://github.com/book-companion/dbt-bookshop.git
cd dbt-bookshop && uv sync && uv run dbt deps && uv run dbt build
```

That ends in:

```
Done. PASS=39 WARN=0 ERROR=0 SKIP=0 NO-OP=1 TOTAL=40
```

`main` may move ahead of the book as dependencies are refreshed. If a command in
the book does not behave as printed, check out the tag before reporting it — that
distinguishes a genuine erratum from ordinary drift in a dependency.
