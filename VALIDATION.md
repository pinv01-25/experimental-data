# Fresh validation record

Validation was performed on 2026-08-31 directly from the retained JSON and CSV outputs. No new simulation was run.

## Completeness and syntax

- 3 baselines × 6 scenarios × 10 seeds = 180 paired comparisons.
- 180 `ab_report.json` files.
- 180 `ab_summary.csv` files.
- 180 `incomplete_trips_A.csv` files.
- 180 `incomplete_trips_B.csv` files.
- All 180 JSON reports parse successfully.
- Each baseline/scenario cell contains the same ten seeds listed in `data/campaign_seeds.json`.

## Verdict totals

| Verdict | Count |
|---|---:|
| `improvement` | 117 |
| `misleading_regression` | 23 |
| `misleading_improvement` | 33 |
| `regression` | 7 |
| **Total** | **180** |

Using the manuscript rule—`improvement` and `misleading_regression` are favorable—the total is 140/180 favorable comparisons:

| Baseline | Favorable | Total |
|---|---:|---:|
| `mopc_60` | 48 | 60 |
| `netconvert_90` | 46 | 60 |
| `largo_120` | 46 | 60 |
| **Overall** | **140** | **180** |

These counts agree with the manuscript tables and discussion.

## Provenance limitation

The campaign did not retain the upstream SUMO `tripinfo.xml`, `summary.xml`, or FCD XML outputs. This validation therefore establishes the internal completeness and consistency of the retained postprocessed reports and trip-censoring lists; it cannot reconstruct the reports independently from the original simulator event stream.

Run `./scripts/validate_dataset.sh` to repeat the repository-level checks.
