"""
AGD Canonical Serialization and Hashing Module
================================================
Provides byte-exact canonical JSON serialization, SHA-256 hashing,
and execution environment manifest generation for absolute determinism.
"""

import json
import hashlib
import platform
import os
import sys
from typing import Any, Dict, Union

def canonical_json_dumps(data: Any) -> str:
    """
    Serializes arbitrary Python data structures into a byte-exact,
    canonical JSON string representation with sorted keys and uniform formatting.
    """
    def _normalize(obj: Any) -> Any:
        if isinstance(obj, dict):
            return {str(k): _normalize(v) for k, v in sorted(obj.items(), key=lambda x: str(x[0]))}
        elif isinstance(obj, (list, tuple)):
            return [_normalize(x) for x in obj]
        elif isinstance(obj, set):
            return [_normalize(x) for x in sorted(obj, key=lambda x: str(x))]
        elif isinstance(obj, float):
            # Format floats deterministically with 6 decimal places to prevent platform float jitter
            return round(obj, 6)
        return obj

    normalized = _normalize(data)
    return json.dumps(
        normalized,
        ensure_ascii=True,
        sort_keys=True,
        indent=None,
        separators=(',', ':')
    )

def sha256_hash(data: Union[str, bytes, Dict, list, Any]) -> str:
    """
    Computes a SHA-256 hexadecimal hash over raw strings, bytes,
    or canonicalized JSON representations.
    """
    if isinstance(data, bytes):
        raw_bytes = data
    elif isinstance(data, str):
        raw_bytes = data.encode('utf-8')
    else:
        raw_bytes = canonical_json_dumps(data).encode('utf-8')

    return hashlib.sha256(raw_bytes).hexdigest()

def get_environment_manifest() -> Dict[str, Any]:
    """
    Captures exact environment details for deterministic audit traceability.
    """
    return {
        "python_version": sys.version.split()[0],
        "platform": platform.platform(),
        "system": platform.system(),
        "architecture": platform.machine(),
        "environment_hash": sha256_hash({
            "sys_version": sys.version,
            "platform": platform.platform(),
            "byteorder": sys.byteorder
        })
    }
