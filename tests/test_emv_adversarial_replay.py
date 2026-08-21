import copy
import json
import subprocess
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from agd.canonical import sha256_hash
from emb.replay_certificate import build_replay_certificate, verify_replay_certificate


def _events():
    return [
        {"event": "SELECT_AID", "state": "APPLICATION_SELECTED", "data": {"aid": "A0000000031010"}},
        {"event": "GET_PROCESSING_OPTIONS", "state": "PROCESSING_OPTIONS", "data": {"amount": "000000001000"}},
        {"event": "READ_RECORD", "state": "RECORD_READ", "data": {"afl": "08010100"}},
        {"event": "GENERATE_AC", "state": "COMPLETED", "data": {"cryptogram_type": "TC"}},
    ]


def _certificate():
    return build_replay_certificate(
        constitution_hash="c" * 64,
        authority_hash="a" * 64,
        environment_hash="e" * 64,
        events=_events(),
        evidence_level="SIMULATED",
    )


def test_repeated_certificate_generation_is_identical():
    assert _certificate() == _certificate()
    assert sha256_hash(_certificate()) == sha256_hash(_certificate())


def test_event_reordering_is_detected():
    cert = _certificate()
    cert["events"] = list(reversed(cert["events"]))
    assert not verify_replay_certificate(cert)


def test_event_deletion_is_detected():
    cert = _certificate()
    cert["events"] = cert["events"][:-1]
    assert not verify_replay_certificate(cert)


def test_event_duplication_is_detected():
    cert = _certificate()
    cert["events"].insert(1, copy.deepcopy(cert["events"][0]))
    assert not verify_replay_certificate(cert)


@pytest.mark.parametrize("field", ["trace_hash", "certificate_hash", "constitution_hash", "authority_hash", "environment_hash"])
def test_certificate_field_mutation_is_detected(field):
    cert = _certificate()
    value = cert[field]
    cert[field] = ("0" if value[0] != "0" else "1") + value[1:]
    assert not verify_replay_certificate(cert)


def test_serialized_certificate_verifies_in_fresh_process(tmp_path):
    cert_path = tmp_path / "certificate.json"
    cert_path.write_text(json.dumps(_certificate(), sort_keys=True))
    result = subprocess.run(
        [sys.executable, str(ROOT / "replay" / "verify_certificate.py"), str(cert_path)],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 0
    assert "CERTIFICATE_VALID" in result.stdout


def test_tampered_serialized_certificate_fails_in_fresh_process(tmp_path):
    cert = _certificate()
    cert["events"][1]["data"]["amount"] = "000000009999"
    cert_path = tmp_path / "tampered.json"
    cert_path.write_text(json.dumps(cert, sort_keys=True))
    result = subprocess.run(
        [sys.executable, str(ROOT / "replay" / "verify_certificate.py"), str(cert_path)],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode != 0
    assert "CERTIFICATE_INVALID" in result.stdout
