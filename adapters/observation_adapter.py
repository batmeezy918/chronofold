"""
Real-World Data Intake Adapters
===============================
Adapts external observations (RF telemetry, Wi-Fi scans, APDU traces, device logs)
into canonical protocol states without modifying constitution rules.
"""

from typing import Dict, Any
from agd.canonical import sha256_hash

class ObservationAdapter:
    """
    Strict boundary adapter enforcing:
    observation -> canonicalization -> state -> quotient -> protocol interpretation -> certificate
    """
    def ingest_raw_rf_observation(self, raw_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Normalizes Termux RF / NFC raw observation into canonical protocol state input.
        """
        raw_hash = sha256_hash(raw_data)

        canonical_obs = {
            "source_type": raw_data.get("source_type", "RF_TELEMETRY"),
            "rssi_dbm": raw_data.get("rssi", -60),
            "frequency_mhz": raw_data.get("frequency", 13560), # 13.56 MHz NFC
            "raw_payload_hex": raw_data.get("payload", "").upper().replace(" ", ""),
            "raw_hash": raw_hash
        }

        # Extract AID or APDU if present in payload
        aid = "A0000000031010" if "A0000000031010" in canonical_obs["raw_payload_hex"] else raw_data.get("aid", "UNKNOWN")

        protocol_state_input = {
            "aid": aid,
            "amount": raw_data.get("amount", "000000001000"),
            "canonical_observation_hash": sha256_hash(canonical_obs)
        }

        return {
            "raw_observation": raw_data,
            "canonical_observation": canonical_obs,
            "protocol_input": protocol_state_input
        }
