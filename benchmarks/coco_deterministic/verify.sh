#!/usr/bin/env bash
set -euo pipefail

export PYTHONHASHSEED=0
rm -rf S6_RESULTS verify_run1.txt verify_run2.txt
python s6_coco_harness.py | tee verify_run1.txt
mv S6_RESULTS S6_RESULTS_1
python s6_coco_harness.py | tee verify_run2.txt
mv S6_RESULTS S6_RESULTS_2
cmp verify_run1.txt verify_run2.txt
cmp S6_RESULTS_1/deterministic_results.json S6_RESULTS_2/deterministic_results.json
cmp S6_RESULTS_1/trace.txt S6_RESULTS_2/trace.txt
echo 'DETERMINISM_CHECK=PASS'
