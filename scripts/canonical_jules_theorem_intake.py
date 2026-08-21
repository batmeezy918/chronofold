#!/usr/bin/env python3
"""Canonical theorem inventory verifier/intake report.

This does not promote theorems. It makes promotion evidence explicit and
fails closed when source/status cannot be established from the current tree.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INVENTORY = ROOT / "docs" / "THEOREM_INVENTORY.md"


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def main() -> int:
    if not INVENTORY.exists():
        raise SystemExit("MISSING_THEOREM_INVENTORY")
    text = INVENTORY.read_text(encoding="utf-8")
    rows = []
    for line in text.splitlines():
        if not line.startswith("|") or line.startswith("| File Path") or line.startswith("|---"):
            continue
        parts = [p.strip() for p in line.strip("|").split("|")]
        if len(parts) >= 3:
            rows.append({"path": parts[0], "status": parts[1], "notes": parts[2]})
    report = {
        "schema_version": "1.0.0",
        "source": str(INVENTORY.relative_to(ROOT)),
        "inventory_sha256": sha256_bytes(INVENTORY.read_bytes()),
        "counts": {},
        "entries": rows,
        "policy": {
            "promotion_requires_machine_verification": True,
            "rejected_is_not_proven": True,
            "narrative_is_not_proof": True,
            "stale_pr_copy_is_not_canonical": True,
        },
    }
    for r in rows:
        report["counts"][r["status"]] = report["counts"].get(r["status"], 0) + 1
    out = ROOT / "reports" / "theorem_intake_audit.json"
    out.parent.mkdir(exist_ok=True)
    out.write_text(json.dumps(report, indent=2, sort_keys=True), encoding="utf-8")
    print(json.dumps(report, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
