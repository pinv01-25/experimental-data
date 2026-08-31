# Data dictionary

## Directory keys

Each run directory has the form `data/runs/<baseline>/<scenario>/seed_<seed>/`.

- `baseline`: one of `mopc_60`, `netconvert_90`, or `largo_120`.
- `scenario`: one of `corredor`, `demanda_alta`, `demanda_baja`, `demanda_media`, `demanda_saturada`, or `hora_pico`.
- `seed`: the paired SUMO random seed. The same seed is used for configurations A and B within a comparison.

Configuration `A` is the fixed-time controller. Configuration `B` is the dynamic hierarchical controller.

## `ab_report.json`

This is the machine-readable record for a paired comparison. Its principal top-level objects are:

| Object | Meaning |
|---|---|
| `labels` | Display names for configurations A and B |
| `run_config` | Campaign mode, baseline configuration, seed, and planned simulation settings |
| `data_info` | Information about the observations used by the report |
| `statistics` | Per-metric descriptive and comparative statistics |
| `summary_statistics` | Aggregated result fields |
| `statistical_tests` | Throughput/system-time tests and the combined verdict |
| `generated_files` | Names of plots produced by the reporting workflow; those plots are not stored here |

Fields exposed in `manifest.csv` are read from:

- `statistical_tests.verdict.verdict`
- `statistical_tests.throughput.throughput_change_pct`
- `statistical_tests.throughput.completed_a`
- `statistical_tests.throughput.completed_b`
- `statistical_tests.system_time.system_time_improvement_pct`

Percentage signs are oriented so that positive values favor configuration B:

- throughput change: `(completed_B - completed_A) / completed_A × 100`;
- system-time improvement: `(system_time_A - system_time_B) / system_time_A × 100`.

## Verdicts

The combined verdict guards against completed-trip survivorship bias:

| Verdict | Interpretation | Favorable in manuscript aggregate? |
|---|---|---|
| `improvement` | The report's combined decision rule classifies B as an improvement | Yes |
| `misleading_regression` | Completed-trip time looks worse, but throughput supports B | Yes |
| `misleading_improvement` | Completed-trip time looks better, but throughput falls | No |
| `regression` | The combined evidence is unfavorable to B | No |

The `favorable` column in `manifest.csv` applies exactly this mapping.

## `ab_summary.csv`

This is a human-readable, sectioned export of the paired report. It contains blocks for metric statistics, statistical-test results, interpretation, and the verdict. It is not a single rectangular data table; use `ab_report.json` or `manifest.csv` for programmatic analysis.

## `incomplete_trips_A.csv` and `incomplete_trips_B.csv`

These files list vehicles that had not completed their trips at the end of the retained observation window.

| Column | Meaning |
|---|---|
| `id` | SUMO vehicle identifier |
| `last_fcd_time` | Last sampled simulation time at which the vehicle was observed |
| `depart` | Vehicle departure time |
| `time_in_network` | Elapsed time in the simulated network at the last observation |

## `campaign_seeds.json`

The ten paired random seeds used in every baseline/scenario cell.

## `manifest.csv`

One row per paired comparison. In addition to the directory keys, verdict, and selected metrics, it stores repository-relative paths to the four retained run files.
