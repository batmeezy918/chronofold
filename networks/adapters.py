"""
Independent Network Protocol Adapters
=====================================
Encapsulates network-specific protocol rules, card/terminal qualifiers,
and message format requirements for Visa, Mastercard, and American Express.
"""

from typing import Dict, Any
from authority.model import AuthorityGraph, Authority, AuthorityType
from networks.bin_ranges import lookup_bin_range

class NetworkAdapter:
    def __init__(self, network_name: str, authority_id: str):
        self.network_name = network_name
        self.authority_id = authority_id

    def process_transaction_context(self, pan: str, transaction_data: Dict[str, Any]) -> Dict[str, Any]:
        bin_info = lookup_bin_range(int(pan[:6]))
        if bin_info["status"] == "UNVERIFIED":
            return {
                "status": "REJECTED_UNVERIFIED_BIN",
                "message": "I don't know.",
                "details": bin_info
            }

        if bin_info["network"] != self.network_name:
            return {
                "status": "REJECTED_NETWORK_MISMATCH",
                "expected": self.network_name,
                "found": bin_info["network"]
            }

        return self.customize_protocol_branch(bin_info, transaction_data)

    def customize_protocol_branch(self, bin_info: Dict[str, Any], transaction_data: Dict[str, Any]) -> Dict[str, Any]:
        raise NotImplementedError

class VisaAdapter(NetworkAdapter):
    def __init__(self):
        super().__init__("VISA", "AUTH_VISA_GLOBAL_SPEC_2024")

    def customize_protocol_branch(self, bin_info: Dict[str, Any], transaction_data: Dict[str, Any]) -> Dict[str, Any]:
        # Visa Contactless uses Terminal Transaction Qualifiers (TTQ - Tag 9F66)
        ttq = transaction_data.get("9F66", "28000000") # Default TTQ
        return {
            "status": "ADMITTED",
            "network": "VISA",
            "protocol_branch": "VIS_VCPS_CONTACTLESS",
            "ttq": ttq,
            "cvm_required": bool(int(ttq[:2], 16) & 0x40), # Check CVM required bit
            "bin_info": bin_info,
            "authority_id": self.authority_id
        }

class MastercardAdapter(NetworkAdapter):
    def __init__(self):
        super().__init__("MASTERCARD", "AUTH_MASTERCARD_MIP_SPEC_2024")

    def customize_protocol_branch(self, bin_info: Dict[str, Any], transaction_data: Dict[str, Any]) -> Dict[str, Any]:
        # Mastercard uses Card Transaction Qualifiers (CTQ - Tag 9F6C)
        ctq = transaction_data.get("9F6C", "0000")
        return {
            "status": "ADMITTED",
            "network": "MASTERCARD",
            "protocol_branch": "MCHIP_CONTACTLESS",
            "ctq": ctq,
            "ipm_message_type": "0100",
            "bin_info": bin_info,
            "authority_id": self.authority_id
        }

class AmexAdapter(NetworkAdapter):
    def __init__(self):
        super().__init__("AMERICAN_EXPRESS", "AUTH_AMEX_GLOBAL_SPEC_2024")

    def customize_protocol_branch(self, bin_info: Dict[str, Any], transaction_data: Dict[str, Any]) -> Dict[str, Any]:
        return {
            "status": "ADMITTED",
            "network": "AMERICAN_EXPRESS",
            "protocol_branch": "EXPRESSPAY_CONTACTLESS",
            "bin_info": bin_info,
            "authority_id": self.authority_id
        }

def register_network_authorities(graph: AuthorityGraph):
    v_auth = Authority(
        authority_id="AUTH_VISA_GLOBAL_SPEC_2024",
        authority_type=AuthorityType.NETWORK,
        organization="Visa Inc.",
        document_id="VIS_VCPS_SPEC",
        version="2.2",
        publication_date="2024-01-15",
        effective_date="2024-01-15",
        scope="GLOBAL",
        network="VISA",
        source_uri="https://developer.visa.com/specifications",
        local_artifact="visa_vcps_spec.json"
    )
    m_auth = Authority(
        authority_id="AUTH_MASTERCARD_MIP_SPEC_2024",
        authority_type=AuthorityType.NETWORK,
        organization="Mastercard Worldwide",
        document_id="MCHIP_ADVANCED_SPEC",
        version="1.4",
        publication_date="2024-02-01",
        effective_date="2024-02-01",
        scope="GLOBAL",
        network="MASTERCARD",
        source_uri="https://developer.mastercard.com/specifications",
        local_artifact="mastercard_mchip_spec.json"
    )
    a_auth = Authority(
        authority_id="AUTH_AMEX_GLOBAL_SPEC_2024",
        authority_type=AuthorityType.NETWORK,
        organization="American Express",
        document_id="EXPRESSPAY_SPEC",
        version="3.1",
        publication_date="2024-03-01",
        effective_date="2024-03-01",
        scope="GLOBAL",
        network="AMERICAN_EXPRESS",
        source_uri="https://developer.americanexpress.com/specifications",
        local_artifact="expresspay_spec.json"
    )

    graph.register_authority(v_auth)
    graph.register_authority(m_auth)
    graph.register_authority(a_auth)
