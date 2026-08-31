# Experimental data for multi-rate adaptive urban traffic control

This repository contains the retained experimental outputs supporting the manuscript **“From Sensing to Signal Actuation: A Multi-Rate System for Adaptive Urban Traffic Control.”**

## Scope

The campaign contains 180 paired comparisons:

- 3 fixed-time baselines;
- 6 demand scenarios;
- 10 paired random seeds per baseline/scenario combination.

In every comparison, configuration `A` is the fixed-time baseline and configuration `B` is the dynamic hierarchical controller.

The fixed-time baseline directories are:

| Directory | Baseline |
|---|---|
| `mopc_60` | MOPC-inspired 60 s cycle, with 25 s green per phase |
| `netconvert_90` | SUMO/netconvert 90 s target cycle, with 42 s green per phase |
| `largo_120` | Long 120 s cycle, with 57 s green per phase |

The scenario directories are `corredor`, `demanda_alta`, `demanda_baja`, `demanda_media`, `demanda_saturada`, and `hora_pico`. The paired seeds are recorded in [`data/campaign_seeds.json`](data/campaign_seeds.json).

## Repository layout

```text
data/
  campaign_seeds.json
  runs/<baseline>/<scenario>/seed_<seed>/
    ab_report.json
    ab_summary.csv
    incomplete_trips_A.csv
    incomplete_trips_B.csv
manifest.csv
DATA_DICTIONARY.md
VALIDATION.md
SHA256SUMS
scripts/
  build_manifest.sh
  validate_dataset.sh
```

`manifest.csv` provides one row per paired comparison and exposes the verdict and the principal throughput/system-time fields without requiring all 180 JSON documents to be opened individually.

## Retained and omitted artifacts

This package includes the compact, evidence-bearing per-run reports and incomplete-trip lists. It excludes 5,760 PNG plots and 180 per-run HTML renderings because they are visual derivatives of the retained report fields and would expand the repository from approximately 4 MB to more than 700 MB.

The original SUMO `tripinfo.xml`, `summary.xml`, and FCD XML outputs were not retained by the campaign and therefore cannot be included here. Consequently, this is a package of postprocessed experimental evidence, not the upstream simulator event stream. No simulations were rerun or new experiments performed while preparing this repository.

Each retained report contains 3,600 sampled rows covering simulation seconds 0 through 3,599. Some `run_config` objects retain the planned `sim_steps` value of 4,500; the reported statistics and manuscript results use the actual 3,600-second observation window present in the data.

## Validate the package

The validation script requires `jq` and `shasum`:

```sh
./scripts/validate_dataset.sh
```

It checks the complete 3 × 6 × 10 matrix, expected file counts, JSON syntax, verdict totals, manifest consistency, and SHA-256 checksums. See [`VALIDATION.md`](VALIDATION.md) for the recorded fresh-validation result and [`DATA_DICTIONARY.md`](DATA_DICTIONARY.md) for field definitions.
