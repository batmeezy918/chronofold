"""Independent verification entrypoint for EMB replay certificates."""
from __future__ import annotations
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from emb.replay_certificate import verify_replay_certificate


def verify_file(path: str) -> bool:
    certificate = json.loads(Path(path).read_text())
    return verify_replay_certificate(certificate)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("usage: python3 replay/verify_certificate.py CERTIFICATE.json")
    ok = verify_file(sys.argv[1])
    print("CERTIFICATE_VALID" if ok else "CERTIFICATE_INVALID")
    raise SystemExit(0 if ok else 1)
