"""Verify a dim10 S6X results.json against the committed golden champion signature.

The champion (v4 d51300d) is byte-reproducible across the CI fleet: the
head-to-head harness reproduces the same per-problem records on 4+ different
runners. A lock-down gate at CI time ensures a heterogeneous runner can NEVER
silently publish divergent sweep/head-to-head evidence (AGENTS.md Rule 3).

The gate compares, per problem id, the trajectory signature recorded by both
production paths (head-to-head harness and projection sweep):

    [best_f, evaluations, restarts, lambda_end, final_target_hit]

On any mismatch the script exits non-zero with a structured diff. Usage:

    python golden_gate.py RESULTS_JSON [GOLDEN_JSON]

    RESULTS_JSON   a dim10 S6X results.json (produced by s6x_head_to_head.py
                   or coco_projection_sweep.py --root ... dim10/S6X)
    GOLDEN_JSON    default: golden/s6x_dim10_champion_signature.json
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

FIELDS = ["best_f", "evaluations", "restarts", "lambda_end", "final_target_hit"]


def signature(results_json: Path) -> dict[str, list[float | int | bool]]:
    payload = json.loads(results_json.read_text())
    rows = payload["results"]
    assert payload["algorithm"] == "S6X"
    assert payload["suite"] == "bbob"
    assert payload["dimension"] == 10
    sig: dict[str, list[float | int | bool]] = {}
    for r in rows:
        pid = r["problem_id"]
        sig[pid] = [r[f] for f in FIELDS]
    return sig


def main(argv: list[str]) -> int:
    if len(argv) not in (1, 2):
        print(f"usage: {Path(argv[0]).name} RESULTS_JSON [GOLDEN_JSON]", file=sys.stderr)
        return 2
    results_json = Path(argv[0])
    here = Path(__file__).resolve().parent
    golden_json = Path(argv[1]) if len(argv) == 2 else here / "golden" / "s6x_dim10_champion_signature.json"

    actual = signature(results_json)
    golden = json.loads(golden_json.read_text())["problems"]

    if sorted(golden) != sorted(actual):
        missing = sorted(set(golden) - set(actual))
        extra = sorted(set(actual) - set(golden))
        print(f"GOLDEN_GATE=FAIL problem-id set mismatch: missing={missing[:5]} extra={extra[:5]}", file=sys.stderr)
        return 1

    diffs: list[dict[str, object]] = []
    for pid in sorted(golden):
        if actual[pid] != golden[pid]:
            row = {"problem_id": pid}
            for idx, f in enumerate(FIELDS):
                row[f] = {"golden": golden[pid][idx], "actual": actual[pid][idx]}
            diffs.append(row)
    if diffs:
        print(f"GOLDEN_GATE=FAIL\n{diffs[0]['problem_id']}: {diffs[0]} ... total {len(diffs)}/360 problems differ")
        return 1
    print(f"GOLDEN_GATE=PASS\n{len(actual)}/360 problems byte-identical to champion signature (sha256 of source: {golden_json.stem})")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))