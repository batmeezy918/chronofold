#!/usr/bin/env python3
"""Phase 10 — machine-readable certificate."""

from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

def load(path: Path):
    if path.exists():
        return json.loads(path.read_text())
    return {}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--artifact-dir", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    ad = Path(args.artifact_dir)
    env = load(ad / "environment.json")
    ver = load(ad / "verification.json")
    stress = load(ad / "stress_results.json")
    manifest = load(ad / "manifest.json")
    official_ref = load(ad / "official_task_reference.json")

    cert = {
        "experiment": "AGD × SV-COMP 2026 Compatible",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "benchmark_definition_tag": "svcomp26",
        "benchmark_corpus_commit": "NOT FETCHED (full clone skipped)",
        "competition_script_commit": "NOT FETCHED",
        "benchexec_version": env.get("benchexec_version", "UNKNOWN"),
        "agd_version_commit": "see GITHUB_SHA in runner",
        "environment_fingerprint": env,
        "official_task_count_reference": official_ref,
        "category_counts": "NOT ENUMERATED",
        "completed_executions": {
            "projection_tasks": manifest.get("synthetic_tasks", 0),
            "stress_replays": stress.get("stress_completed", 0),
            "verification_runs": 0,
        },
        "UNKNOWN_count": 0,
        "TRUE_count": 0,
        "FALSE_count": 0,
        "incorrect_result_count": 0,
        "deterministic_replay_count": stress.get("stress_completed", 0),
        "deterministic_mismatch_count": stress.get("mismatches", 0),
        "exact_trace_equality_count": stress.get("exact_matches", 0),
        "certificate_equality_count": stress.get("exact_matches", 0),
        "stress_test_target": 57797270,
        "stress_test_completed_count": 0,
        "stress_test_failure_count": 0,
        "actual_stress_performed": stress.get("stress_completed", 0),
        "determinism_rate": stress.get("determinism_rate", 0.0),
        "runtime": {
            "stress_wall_seconds": stress.get("wall_seconds"),
        },
        "claim_classes": {
            "A_directly_established": [
                "Environment fingerprint recorded",
                "BenchExec installed",
                "Deterministic AGD projection pipeline executed on synthetic tasks",
                "Deterministic replay stress executed and measured",
            ],
            "B_empirically_observed": [
                "Projection hash equality under repeated execution",
            ],
            "C_hypotheses": [],
            "D_not_tested": [
                "Official SV-COMP task verification",
                "Full 36 402 C + 1 731 Java corpus",
                "57 797 270 official-scale stress",
                "Witness validation",
                "Independent verifier cross-check",
                "Semantic equivalence of projections",
            ],
        },
        "status": "PARTIAL — verification and full stress NOT EXECUTED",
    }

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(cert, indent=2))
    print(f"Wrote {out}")

if __name__ == "__main__":
    main()
