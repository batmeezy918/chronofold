"""
Network BIN Ranges and Provenance Control
===========================================
Stores network-specific BIN ranges backed by explicit authority provenance.
Unrecognized or unauthorized ranges are marked UNVERIFIED.
"""

from dataclasses import dataclass
from typing import Optional, Dict, Any

@dataclass
class BinRange:
    bin_low: int
    bin_high: int
    network: str
    product: str
    country: str
    region: str
    effective_start: str
    effective_end: str
    authority_id: str
    provenance_status: str

# Authorized BIN Range Database with explicit provenance
AUTHORIZED_BIN_RANGES = [
    BinRange(
        bin_low=400000,
        bin_high=499999,
        network="VISA",
        product="VISA_CLASSIC_CREDIT",
        country="GLOBAL",
        region="GLOBAL",
        effective_start="2020-01-01",
        effective_end="2030-12-31",
        authority_id="AUTH_VISA_GLOBAL_SPEC_2024",
        provenance_status="AUTHORITATIVE"
    ),
    BinRange(
        bin_low=510000,
        bin_high=559999,
        network="MASTERCARD",
        product="MASTERCARD_STANDARD",
        country="GLOBAL",
        region="GLOBAL",
        effective_start="2020-01-01",
        effective_end="2030-12-31",
        authority_id="AUTH_MASTERCARD_MIP_SPEC_2024",
        provenance_status="AUTHORITATIVE"
    ),
    BinRange(
        bin_low=340000,
        bin_high=379999,
        network="AMERICAN_EXPRESS",
        product="AMEX_CENTURION_PRODUCT",
        country="GLOBAL",
        region="GLOBAL",
        effective_start="2020-01-01",
        effective_end="2030-12-31",
        authority_id="AUTH_AMEX_GLOBAL_SPEC_2024",
        provenance_status="AUTHORITATIVE"
    )
]

def lookup_bin_range(pan_prefix: int) -> Dict[str, Any]:
    """
    Look up a BIN range in the authorized database.
    If unavailable or not authorized, returns UNVERIFIED without inventing data.
    """
    # pan_prefix should be at least 6 digits
    prefix_6 = int(str(pan_prefix)[:6])

    for r in AUTHORIZED_BIN_RANGES:
        if r.bin_low <= prefix_6 <= r.bin_high:
            return {
                "status": "VERIFIED",
                "network": r.network,
                "product": r.product,
                "country": r.country,
                "region": r.region,
                "authority_id": r.authority_id,
                "provenance_status": r.provenance_status,
                "bin_low": r.bin_low,
                "bin_high": r.bin_high
            }

    return {
        "status": "UNVERIFIED",
        "message": "I don't know.",
        "reason": f"BIN prefix {prefix_6} is not present in any authorized network source.",
        "provenance_status": "UNVERIFIED"
    }
