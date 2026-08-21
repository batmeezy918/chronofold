"""
Differential Testing Engine
===========================
Executes differential verification between the primary protocol kernel
and independent secondary test oracles (e.g. PaymentCardTools).
"""

from typing import Dict, Any, List
from references.payment_card_tools import PaymentCardToolsOracle
from agd.canonical import sha256_hash

class DifferentialEngine:
    def __init__(self):
        self.oracle = PaymentCardToolsOracle()

    def test_tlv_parsing(self, tlv_hex_cases: List[str]) -> Dict[str, Any]:
        """
        Runs differential tests across TLV hex strings.
        """
        results = []
        conflicts = 0

        for tlv_hex in tlv_hex_cases:
            # Our implementation parsing
            our_parsed = self._our_parse_tlv(tlv_hex)

            # Differential comparison via PaymentCardTools
            comp = self.oracle.run_differential_comparison("TLV_PARSING", tlv_hex, our_parsed)
            results.append(comp)

            if comp["comparison_result"] == "DIFFERENTIAL_CONFLICT":
                conflicts += 1

        return {
            "total_cases": len(tlv_hex_cases),
            "conflicts": conflicts,
            "passed": conflicts == 0,
            "results": results
        }

    def _our_parse_tlv(self, hex_string: str) -> List[Dict[str, Any]]:
        """
        Kernel TLV parsing logic.
        """
        results = []
        i = 0
        hex_string = hex_string.upper().replace(" ", "")

        while i < len(hex_string):
            tag = hex_string[i:i+2]
            i += 2
            if (int(tag, 16) & 0x1F) == 0x1F:
                tag += hex_string[i:i+2]
                i += 2

            if i >= len(hex_string):
                break

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
