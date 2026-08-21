import copy
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

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


class EMVAdversarialReplayTests(unittest.TestCase):
    def test_repeated_certificate_generation_is_identical(self):
        self.assertEqual(_certificate(), _certificate())
        self.assertEqual(sha256_hash(_certificate()), sha256_hash(_certificate()))

    def test_event_reordering_is_detected(self):
        cert = _certificate(); cert["events"] = list(reversed(cert["events"]))
        self.assertFalse(verify_replay_certificate(cert))

    def test_event_deletion_is_detected(self):
        cert = _certificate(); cert["events"] = cert["events"][:-1]
        self.assertFalse(verify_replay_certificate(cert))

    def test_event_duplication_is_detected(self):
        cert = _certificate(); cert["events"].insert(1, copy.deepcopy(cert["events"][0]))
        self.assertFalse(verify_replay_certificate(cert))

    def test_certificate_field_mutations_are_detected(self):
        for field in ("trace_hash", "certificate_hash", "constitution_hash", "authority_hash", "environment_hash"):
            with self.subTest(field=field):
                cert = _certificate(); value = cert[field]
                cert[field] = ("0" if value[0] != "0" else "1") + value[1:]
                self.assertFalse(verify_replay_certificate(cert))

    def test_serialized_certificate_verifies_in_fresh_process(self):
        with tempfile.TemporaryDirectory() as td:
            cert_path = Path(td) / "certificate.json"
            cert_path.write_text(json.dumps(_certificate(), sort_keys=True))
            result = subprocess.run([sys.executable, str(ROOT / "replay" / "verify_certificate.py"), str(cert_path)], capture_output=True, text=True, check=False)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("CERTIFICATE_VALID", result.stdout)

    def test_tampered_serialized_certificate_fails_in_fresh_process(self):
        cert = _certificate(); cert["events"][1]["data"]["amount"] = "000000009999"
        with tempfile.TemporaryDirectory() as td:
            cert_path = Path(td) / "tampered.json"
            cert_path.write_text(json.dumps(cert, sort_keys=True))
            result = subprocess.run([sys.executable, str(ROOT / "replay" / "verify_certificate.py"), str(cert_path)], capture_output=True, text=True, check=False)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("CERTIFICATE_INVALID", result.stdout)


if __name__ == "__main__":
    unittest.main()
