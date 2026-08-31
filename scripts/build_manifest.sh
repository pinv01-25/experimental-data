#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
output="$repo_root/manifest.csv"

printf '%s\n' 'baseline,scenario,seed,verdict,favorable,throughput_change_pct,system_time_improvement_pct,completed_a,completed_b,report_json,summary_csv,incomplete_a_csv,incomplete_b_csv' > "$output"

find "$repo_root/data/runs" -name ab_report.json -type f | LC_ALL=C sort | while IFS= read -r report; do
  relative=${report#"$repo_root/"}
  run_dir=${relative%/ab_report.json}
  rest=${run_dir#data/runs/}
  baseline=${rest%%/*}
  rest=${rest#*/}
  scenario=${rest%%/*}
  seed_dir=${rest##*/}
  seed=${seed_dir#seed_}

  jq -r \
    --arg baseline "$baseline" \
    --arg scenario "$scenario" \
    --arg seed "$seed" \
    --arg report "$relative" \
    --arg summary "$run_dir/ab_summary.csv" \
    --arg incomplete_a "$run_dir/incomplete_trips_A.csv" \
    --arg incomplete_b "$run_dir/incomplete_trips_B.csv" \
    '[
      $baseline,
      $scenario,
      $seed,
      .statistical_tests.verdict.verdict,
      ((.statistical_tests.verdict.verdict == "improvement") or
       (.statistical_tests.verdict.verdict == "misleading_regression")),
      .statistical_tests.throughput.throughput_change_pct,
      .statistical_tests.system_time.system_time_improvement_pct,
      .statistical_tests.throughput.completed_a,
      .statistical_tests.throughput.completed_b,
      $report,
      $summary,
      $incomplete_a,
      $incomplete_b
    ] | @csv' "$report" >> "$output"
done
