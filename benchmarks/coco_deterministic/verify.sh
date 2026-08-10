#!/usr/bin/env bash
set -euo pipefail

export PYTHONHASHSEED=0
rm -rf S6_RESULTS S6_RESULTS_1 S6_RESULTS_2 exdata verify_run1.txt verify_run2.txt

python s6_coco_harness.py 2>&1 | grep -v '^COCO INFO:' | tee verify_run1.txt
mv S6_RESULTS S6_RESULTS_1

python s6_coco_harness.py 2>&1 | grep -v '^COCO INFO:' | tee verify_run2.txt
mv S6_RESULTS S6_RESULTS_2

cmp verify_run1.txt verify_run2.txt
cmp S6_RESULTS_1/deterministic_results.json S6_RESULTS_2/deterministic_results.json
cmp S6_RESULTS_1/trace.txt S6_RESULTS_2/trace.txt
cmp S6_RESULTS_1/determinism_manifest.json S6_RESULTS_2/determinism_manifest.json
echo 'DETERMINISM_CHECK=PASS'
python3 -c 'import json; m=json.load(open("S6_RESULTS_1/determinism_manifest.json")); print("results_sha256="+m["results_sha256"]); print("trace_sha256="+m["trace_sha256"]); print("problem_count="+str(m["problem_count"]))'
