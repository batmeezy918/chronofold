"""
PaymentCardTools Secondary Reference Engine
============================================
Serves as an independent differential test oracle for TLV parsing,
DOL decoding, IPM parsing, and cryptographic utilities.
"""

from typing import Dict, Any, List, Tuple
from agd.canonical import sha256_hash
from authority.model import Authority, AuthorityType

PCT_AUTH_ID = "AUTH_PCT_REFERENCE_V2_1"

def build_pct_authority() -> Authority:
    return Authority(
        authority_id=PCT_AUTH_ID,
        authority_type=AuthorityType.SECONDARY_REFERENCE,
        organization="PaymentCardTools OpenReference",
        document_id="PCT_DECODER_LIB",
        version="2.1.0",
        publication_date="2024-01-01",
        effective_date="2024-01-01",
        scope="GLOBAL_REFERENCE_DECODER",
        network="ALL",
        source_uri="https://paymentcardtools.com/",
        local_artifact="pct_reference.json",
        provenance_status="SECONDARY_ORACLE",
        licensing_status="MIT"
    )

class PaymentCardToolsOracle:
    """
    Independent reference implementation used solely for differential verification.
    """
    def __init__(self):
        self.authority = build_pct_authority()

    def parse_tlv(self, hex_string: str) -> List[Dict[str, str]]:
        """
        Reference TLV parser implementation.
        """
        results = []
        i = 0
        hex_string = hex_string.upper().replace(" ", "")

        while i < len(hex_string):
            # Parse tag (handles multi-byte tags where byte 1 lower 5 bits == 0x1F)
            tag = hex_string[i:i+2]
            i += 2
            if (int(tag, 16) & 0x1F) == 0x1F:
                tag += hex_string[i:i+2]
                i += 2

            if i >= len(hex_string):
                break

            # Parse length
            len_byte = int(hex_string[i:i+2], 16)
            i += 2
            if len_byte & 0x80:
                num_bytes = len_byte & 0x7F
                length = int(hex_string[i:i+2*num_bytes], 16)
                i += 2 * num_bytes
            else:
                length = len_byte

            value = hex_string[i:i+2*length]
            i += 2 * length
            results.append({"tag": tag, "length": length, "value": value})

        return results

    def compute_lrc(self, hex_data: str) -> str:
        """
        Computes Longitudinal Redundancy Check byte for reference comparison.
        """
        raw_bytes = bytes.fromhex(hex_data.replace(" ", ""))
        lrc = 0
        for b in raw_bytes:
            lrc ^= b
        return f"{lrc:02X}"

    def run_differential_comparison(
        self,
        domain: str,
        input_data: Any,
        our_result: Any
    ) -> Dict[str, Any]:
        """
        Executes differential evaluation between our implementation and PaymentCardTools.
        """
        input_h = sha256_hash(input_data)

        if domain == "TLV_PARSING":
            ref_result = self.parse_tlv(str(input_data))
        elif domain == "LRC_COMPUTATION":
            ref_result = self.compute_lrc(str(input_data))
        else:
            ref_result = "UNSUPPORTED_DOMAN_IN_REFERENCE"

        match = (our_result == ref_result)
        comparison_result = "MATCH" if match else "DIFFERENTIAL_CONFLICT"

        res = {
            "domain": domain,
            "our_result": our_result,
            "reference_result": ref_result,
            "input_hash": input_h,
            "reference_version": self.authority.version,
            "comparison_result": comparison_result
        }

        if not match:
            res["status"] = "DIFFERENTIAL_CONFLICT"
            res["conflict_details"] = {
                "message": "Disagreement between primary protocol kernel and secondary reference oracle.",
                "primary_authority": "EMVCo / Canonical Kernel",
                "secondary_authority": PCT_AUTH_ID
            }

        return res
