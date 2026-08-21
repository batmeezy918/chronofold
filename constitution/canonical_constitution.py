"""
Canonical EMB Protocol Constitution Instantiation
==================================================
Builds the canonical versioned machine-readable constitution linking EMVCo,
Visa, Mastercard, and Amex authorities.
"""

from constitution.model import Constitution

def build_canonical_constitution() -> Constitution:
    return Constitution(
        constitution_id="CONST_EMB_GLOBAL_V1_0",
        constitution_version="1.0.0",
        authority_set=[
            "AUTH_EMVCO_BOOK_3_V43",
            "AUTH_VISA_GLOBAL_SPEC_2024",
            "AUTH_MASTERCARD_MIP_SPEC_2024",
            "AUTH_AMEX_GLOBAL_SPEC_2024"
        ],
        schema_version="1.0.0",
        state_schema={
            "sequence_number": "int",
            "stage": "str",
            "card_state": "dict",
            "transaction_context": "dict"
        },
        equivalence_relation={
            "canonical_fields": ["sequence_number", "stage", "card_state.aid", "transaction_context.amount"],
            "ignored_fields": ["timestamp_raw", "debug_metadata", "ephemeral_channel_id"]
        },
        invariants=[
            {
                "rule_id": "INV_SEQ_NON_NEGATIVE",
                "authority_id": "AUTH_EMVCO_BOOK_3_V43",
                "field": "sequence_number",
                "type": "int",
                "min": 0,
                "description": "Sequence number must be a non-negative integer."
            },
            {
                "rule_id": "INV_STAGE_STRING",
                "authority_id": "AUTH_EMVCO_BOOK_3_V43",
                "field": "stage",
                "type": "str",
                "description": "Protocol stage must be a string identifier."
            }
        ],
        lawful_operators=[
            "OP_SELECT_AID",
            "OP_GET_PROCESSING_OPTIONS",
            "OP_READ_RECORD",
            "OP_GENERATE_AC",
            "OP_VERIFY_PIN",
            "OP_TERMINAL_RISK_MANAGEMENT"
        ],
        forbidden_operators=[
            "OP_FORGED_AC",
            "OP_BYPASS_PIN",
            "OP_TRUNCATE_CRYPTOGRAM",
            "OP_REPLAY_ATC"
        ],
        admission_rules=[
            {
                "rule_id": "ADM_GPO_REQUIRES_SELECT",
                "authority_id": "AUTH_EMVCO_BOOK_3_V43",
                "operator": "OP_GET_PROCESSING_OPTIONS",
                "required_prev_states": ["SELECTED"],
                "description": "GPO command can only be executed after application selection."
            },
            {
                "rule_id": "ADM_GENERATE_AC_REQUIRES_GPO",
                "authority_id": "AUTH_EMVCO_BOOK_3_V43",
                "operator": "OP_GENERATE_AC",
                "required_prev_states": ["GPO_COMPLETED", "RECORDS_READ"],
                "description": "Generate AC command can only be executed after GPO or Read Record."
            }
        ],
        projection_rules={
            "quotient_map": "Phi(s) = (Omega(s), C(s))",
            "invariant_preservation": True
        },
        reconstruction_rules={
            "deterministic_reconstruction": True
        },
        error_rules={
            "illegal_transition": "STRUCTURED_REJECTION"
        },
        evidence_rules={
            "certificate_required": True
        }
    )
