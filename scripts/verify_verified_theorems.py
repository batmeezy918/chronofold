#!/usr/bin/env python3
"""Fail-closed audit for the canonical Verified Theorems manifest.

This is an inventory gate, not a substitute for Lean. Lean CI remains the
source of truth for compilation/proof validity.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "core" / "verified_theorems" / "MANIFEST.json"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    data = json.loads(MANIFEST.read_text(encoding="utf-8"))
    if data["promotion_policy"]["allow_sorry"]:
        raise SystemExit("INVALID_POLICY_ALLOW_SORRY")
    for entry in data["entries"]:
        source = ROOT / entry["source"]
        if not source.is_file():
            raise SystemExit(f"MISSING_SOURCE:{entry['source']}")
        actual = sha256(source)
        if actual != entry["content_sha256"]:
            raise SystemExit(
                f"SOURCE_HASH_MISMATCH:{entry['source']}:{actual}!={entry['content_sha256']}"
            )
        text = source.read_text(encoding="utf-8")
        if "sorry" in text:
            raise SystemExit(f"SORRY_FOUND:{entry['source']}")
    print(f"VERIFIED_THEOREM_MANIFEST_OK:{len(data['entries'])}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
