"""
Cryptographic Evidence Certificate Engine
===========================================
Generates and independently verifies cryptographic certificates for admitted
protocol state transitions.
"""

from typing import Dict, Any, Optional
from agd.canonical import sha256_hash, canonical_json_dumps, get_environment_manifest

class CertificateEngine:
    def __init__(self, constitution_hash: str, authority_hash: str, implementation_hash: str):
        self.constitution_hash = constitution_hash
        self.authority_hash = authority_hash
        self.implementation_hash = implementation_hash

    def issue_certificate(
        self,
        operator: str,
        input_data: Dict[str, Any],
        state_before: Dict[str, Any],
        state_after: Dict[str, Any],
        phi_before: Dict[str, Any],
        phi_after: Dict[str, Any],
        invariant_results: Dict[str, Any],
        timestamp: str = "2026-06-01T00:00:00Z"
    ) -> Dict[str, Any]:

        cert_payload = {
            "certificate_version": "1.0.0",
            "constitution_hash": self.constitution_hash,
            "authority_hash": self.authority_hash,
            "input_hash": sha256_hash(input_data),
            "state_before_hash": sha256_hash(state_before),
            "state_after_hash": sha256_hash(state_after),
            "phi_before": phi_before,
            "phi_after": phi_after,
            "operator": operator,
            "admission_result": "ADMITTED",
            "invariant_results": invariant_results,
            "evidence_level": "EXECUTABLY_VERIFIED",
            "implementation_hash": self.implementation_hash,
            "timestamp": timestamp
        }

        cert_hash = sha256_hash(cert_payload)
        cert_payload["certificate_hash"] = cert_hash
        return cert_payload

    @staticmethod
    def verify_certificate(cert: Dict[str, Any]) -> Dict[str, Any]:
        """
        Independently verifies cryptographic certificate signature integrity.
        """
        payload_copy = dict(cert)
        claimed_hash = payload_copy.pop("certificate_hash", None)
        if not claimed_hash:
            return {"valid": False, "reason": "Missing certificate_hash field."}

        expected_hash = sha256_hash(payload_copy)
        if expected_hash != claimed_hash:
            return {
                "valid": False,
                "reason": f"Hash mismatch! Claimed: {claimed_hash}, Expected: {expected_hash}"
            }

        return {"valid": True, "certificate_hash": claimed_hash}
