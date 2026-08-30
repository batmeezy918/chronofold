from __future__ import annotations

import hashlib
import json
from typing import Any


def canonicalize(value: Any) -> Any:
    if isinstance(value, dict):
        return {
            str(k): canonicalize(value[k])
            for k in sorted(value.keys(), key=str)
        }

    if isinstance(value, list):
        return [canonicalize(v) for v in value]

    if isinstance(value, tuple):
        return [canonicalize(v) for v in value]

    if hasattr(value, "model_dump"):
        return canonicalize(value.model_dump(mode="json"))

    return value


def canonical_json(value: Any) -> str:
    return json.dumps(
        canonicalize(value),
        sort_keys=True,
        separators=(",", ":"),
        ensure_ascii=False,
    )


def sha256(value: Any) -> str:
    payload = canonical_json(value).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def hash_chain(previous_hash: str, value: Any) -> str:
    return sha256({
        "previous": previous_hash,
        "value": value,
    })
