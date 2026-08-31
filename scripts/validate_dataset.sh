#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

command -v jq >/dev/null 2>&1 || { echo 'error: jq is required' >&2; exit 1; }
command -v shasum >/dev/null 2>&1 || { echo 'error: shasum is required' >&2; exit 1; }

assert_count() {
  pattern=$1
  expected=$2
  actual=$(find data/runs -name "$pattern" -type f | wc -l | tr -d ' ')
  if [ "$actual" -ne "$expected" ]; then
    echo "error: expected $expected $pattern files, found $actual" >&2
    exit 1
  fi
  printf '%-25s %s\n' "$pattern" "$actual"
}

assert_count ab_report.json 180
assert_count ab_summary.csv 180
assert_count incomplete_trips_A.csv 180
assert_count incomplete_trips_B.csv 180

find data/runs -name ab_report.json -type f -exec jq empty {} +
echo 'JSON reports              valid'

expected_seeds=$(jq -r '.[]' data/campaign_seeds.json | LC_ALL=C sort | tr '\n' ' ')
expected_baselines='largo_120 mopc_60 netconvert_90 '
actual_baselines=$(find data/runs -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | LC_ALL=C sort | tr '\n' ' ')
if [ "$actual_baselines" != "$expected_baselines" ]; then
  echo "error: baseline directories do not match the campaign design" >&2
  exit 1
fi

expected_scenarios='corredor demanda_alta demanda_baja demanda_media demanda_saturada hora_pico '
for baseline in data/runs/*; do
  actual_scenarios=$(find "$baseline" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | LC_ALL=C sort | tr '\n' ' ')
  if [ "$actual_scenarios" != "$expected_scenarios" ]; then
    echo "error: scenario directories do not match the campaign design in $baseline" >&2
    exit 1
  fi
done

for cell in data/runs/*/*; do
  actual_seeds=$(find "$cell" -mindepth 1 -maxdepth 1 -type d -name 'seed_*' -exec basename {} \; | sed 's/^seed_//' | LC_ALL=C sort | tr '\n' ' ')
  if [ "$actual_seeds" != "$expected_seeds" ]; then
    echo "error: seed matrix mismatch in $cell" >&2
    exit 1
  fi
done
echo 'Campaign matrix           3 baselines x 6 scenarios x 10 seeds'

verdict_counts=$(find data/runs -name ab_report.json -type f -exec jq -r '.statistical_tests.verdict.verdict' {} + | LC_ALL=C sort | uniq -c | awk '{print $2 "=" $1}' | tr '\n' ' ')
expected_verdicts='improvement=117 misleading_improvement=33 misleading_regression=23 regression=7 '
if [ "$verdict_counts" != "$expected_verdicts" ]; then
  echo "error: unexpected verdict counts: $verdict_counts" >&2
  exit 1
fi
echo "Verdicts                  $verdict_counts"

manifest_rows=$(awk 'END { print NR - 1 }' manifest.csv)
if [ "$manifest_rows" -ne 180 ]; then
  echo "error: expected 180 manifest rows, found $manifest_rows" >&2
  exit 1
fi

manifest_favorable=$(awk -F, 'NR > 1 && $5 == "true" { n++ } END { print n + 0 }' manifest.csv)
if [ "$manifest_favorable" -ne 140 ]; then
  echo "error: expected 140 favorable manifest rows, found $manifest_favorable" >&2
  exit 1
fi
echo 'Manifest                  180 rows; 140 favorable'

shasum -a 256 -c SHA256SUMS >/dev/null
echo 'SHA-256 checksums         valid'
echo 'Validation complete.'
