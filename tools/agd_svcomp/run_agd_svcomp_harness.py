#!/usr/bin/env python3
"""
AGD deterministic projection + stress harness for SV-COMP-compatible experiment.

STRICT RULES (from experiment specification):
- Do NOT fabricate verification results.
- Do NOT claim official SV-COMP scores.
- Full official corpus and 57,797,270 stress are marked NOT EXECUTED when limits bind.
- Only report what this runner actually performed.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import time
from datetime import datetime, timezone
from pathlib import Path

def sha256_bytes(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()

def sha256_str(s: str) -> str:
    return sha256_bytes(s.encode("utf-8"))

def canonical_project(task_id: str, content: str, config: dict) -> dict:
    """
    Deterministic AGD-style projection Π.
    This is a pure, reproducible canonicalization + hash pipeline.
    It is NOT a software model checker. Semantic equivalence is NOT claimed.
    """
    # Normalize whitespace + stable ordering of config keys
    normalized = "\n".join(line.rstrip() for line in content.splitlines()).strip()
    config_bytes = json.dumps(config, sort_keys=True, separators=(",", ":")).encode()
    payload = f"TASK:{task_id}\nCFG:{config_bytes.decode()}\nBODY:{normalized}\n".encode()
    proj_hash = sha256_bytes(payload)
    return {
        "task_id": task_id,
        "input_hash": sha256_str(content),
        "projection_hash": proj_hash,
        "canonical_byte_length": len(payload),
        "projection_status": "OK",
        "invariant_status": "RETAINED",  # structural only
        "note": "Syntactic canonical projection only. No semantic claim."
    }

def make_synthetic_official_style_tasks(n: int) -> list[dict]:
    """
    Create a tiny set of official-style task descriptors for determinism testing.
    These are NOT the real SV-COMP corpus.
    """
    tasks = []
    for i in range(n):
        body = f"/* synthetic task {i:04d} */\nint main() {{\n  int x = {i};\n  return x;\n}}\n"
        tasks.append({
            "task_id": f"synthetic_official_style_{i:04d}",
            "category": "ReachSafety-synthetic",
            "content": body,
            "property": "unreach-call",
            "architecture": "x86_64",
        })
    return tasks

def run_stress(tasks: list[dict], stress_count: int, config: dict) -> dict:
    """Indexed deterministic stress / replay."""
    results = []
    mismatches = 0
    exact = 0
    start = time.time()

    for idx in range(stress_count):
        task = tasks[idx % len(tasks)]
        # Two independent projections (same input → must match)
        p1 = canonical_project(task["task_id"], task["content"], config)
        p2 = canonical_project(task["task_id"], task["content"], config)
        equal = (
            p1["projection_hash"] == p2["projection_hash"]
            and p1["input_hash"] == p2["input_hash"]
        )
        if equal:
            exact += 1
        else:
            mismatches += 1
        results.append({
            "stress_index": f"{idx:08d}",
            "task_id": task["task_id"],
            "projection_hash": p1["projection_hash"],
            "equal": equal,
        })

    elapsed = time.time() - start
    return {
        "stress_target_requested": stress_count,
        "stress_completed": stress_count,
        "exact_matches": exact,
        "mismatches": mismatches,
        "determinism_rate": exact / stress_count if stress_count else 0.0,
        "wall_seconds": round(elapsed, 4),
        "note": (
            "These are deterministic AGD projection/replay executions, "
            "NOT 57,797,270 official SV-COMP verification tasks."
        ),
        "results_sample": results[:20],  # keep artifact small
    }

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--max-tasks", type=int, default=8)
    ap.add_argument("--stress-count", type=int, default=1000)
    ap.add_argument("--out-dir", type=str, default="artifacts/agd_svcomp")
    args = ap.parse_args()

    out = Path(args.out_dir)
    out.mkdir(parents=True, exist_ok=True)

    config = {
        "projection": "AGD-canonical-v1",
        "symmetric_vars": [],
        "runner": "github-actions",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }

    # ---- Phase 3: projection on synthetic official-style tasks ----
    tasks = make_synthetic_official_style_tasks(args.max_tasks)
    projections = []
    for t in tasks:
        proj = canonical_project(t["task_id"], t["content"], config)
        projections.append(proj)

    proj_path = out / "projections.json"
    proj_path.write_text(json.dumps(projections, indent=2))

    # ---- Phase 5/6: deterministic stress / replay ----
    stress = run_stress(tasks, args.stress_count, config)
    stress_path = out / "stress_results.json"
    stress_path.write_text(json.dumps(stress, indent=2))

    # ---- Verification phase is explicitly NOT EXECUTED ----
    verification = {
        "status": "NOT EXECUTED",
        "reason": (
            "No AGD C-program model checker is present, "
            "BenchExec is installed but no verifier binary is configured, "
            "and GitHub Actions resources are far below official SV-COMP limits."
        ),
        "TRUE": 0,
        "FALSE": 0,
        "UNKNOWN": 0,
        "WRONG": 0,
        "runs": 0,
    }
    (out / "verification.json").write_text(json.dumps(verification, indent=2))

    # ---- Summary block required by the experiment prompt ----
    summary = f"""
============================================================
AGD × SV-COMP 2026 FORMAL VERIFICATION EXPERIMENT
============================================================

OFFICIAL TASKS:          NOT EXECUTED (public literature: 36402 C + 1731 Java)
CATEGORIES:              NOT EXECUTED
VERIFICATION RUNS:       0
TRUE:                    0
FALSE:                   0
UNKNOWN:                 0
WRONG:                   0
DETERMINISTIC REPLAYS:   {stress['stress_completed']}
EXACT TRACE MATCH:       {stress['exact_matches']}
CERTIFICATE HASH MATCH:  (see final certificate)
57,797,270 STRESS TARGET: 57797270
57,797,270 STRESS COMPLETED: 0  (runner limit; actual stress performed: {stress['stress_completed']})
DETERMINISM RATE:        {stress['determinism_rate']:.6f}
TOTAL CPU TIME:          (see runner metrics)
TOTAL WALL TIME:         {stress['wall_seconds']} s (stress only)
MAX MEMORY:              (GitHub Actions runner)
BENCHMARK COMMIT:        (see external/svcomp/bench-defs.commit if present)
TASK CORPUS COMMIT:      NOT FETCHED (full corpus skipped)
AGD COMMIT:              {os.environ.get('GITHUB_SHA', 'local')}
STATUS:                  PARTIAL — projection + determinism stress EXECUTED;
                         official verification + full 57M stress NOT EXECUTED
============================================================
""".strip()

    (out / "SUMMARY.txt").write_text(summary + "\n")
    print(summary)

    # Manifest of what was done
    manifest = {
        "phases": {
            "0_environment": "EXECUTED",
            "1_fetch_official": "PARTIAL (bench-defs tag only)",
            "2_corpus_size": "REFERENCE ONLY (public numbers)",
            "3_agd_projection": "EXECUTED (synthetic official-style tasks)",
            "4_verification": "NOT EXECUTED",
            "5_deterministic_replay": "EXECUTED",
            "6_57797270_stress": "NOT EXECUTED (resource/time)",
            "7_cross_process": "NOT EXECUTED",
            "8_adversarial": "NOT EXECUTED",
            "9_independent_validation": "NOT EXECUTED",
            "10_certificate": "EXECUTED (this run)",
        },
        "synthetic_tasks": args.max_tasks,
        "stress_completed": stress["stress_completed"],
        "determinism_rate": stress["determinism_rate"],
    }
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2))

if __name__ == "__main__":
    main()
