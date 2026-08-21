"""
EMVCo Root Technical Authority
==============================
Provides canonical EMVCo technical authority definitions and machine-readable
protocol specifications with full provenance tracking.
"""

from authority.model import Authority, AuthorityType, AuthorityGraph

EMVCO_AUTH_ID = "AUTH_EMVCO_BOOK_3_V43"

def build_emvco_authority() -> Authority:
    return Authority(
        authority_id=EMVCO_AUTH_ID,
        authority_type=AuthorityType.EMVCO,
        organization="EMVCo",
        document_id="EMV_BOOK_3",
        version="4.3",
        publication_date="2011-11-01",
        effective_date="2011-11-01",
        supersedes="EMV_BOOK_3_V4.2",
        scope="GLOBAL_GENERIC_EMV",
        jurisdiction="GLOBAL",
        network="ALL",
        product="CONTACT_CONTACTLESS",
        source_uri="https://www.emvco.com/specifications/emv-book-3-application-specification/",
        local_artifact="emv_book_3_v43_spec.json",
        provenance_status="AUTHORITATIVE",
        licensing_status="PERMITTED_SPEC_EXCERPT"
    )

def register_emvco_rules(graph: AuthorityGraph):
    auth = build_emvco_authority()
    graph.register_authority(auth)

    # Core EMV Tags Specification
    graph.add_rule(
        rule_id="EMV_TAG_82",
        topic="TAG_DICTIONARY",
        content={
            "tag": "82",
            "name": "Application Interchange Profile (AIP)",
            "format": "binary",
            "length": 2,
            "description": "Indicates the capabilities of the application to support specific functions."
        },
        authority_id=EMVCO_AUTH_ID
    )

    graph.add_rule(
        rule_id="EMV_TAG_9F02",
        topic="TAG_DICTIONARY",
        content={
            "tag": "9F02",
            "name": "Amount, Authorised (Numeric)",
            "format": "n 12",
            "length": 6,
            "description": "Authorised amount of transaction (excluding adjustments)."
        },
        authority_id=EMVCO_AUTH_ID
    )

    graph.add_rule(
        rule_id="EMV_TAG_9F26",
        topic="TAG_DICTIONARY",
        content={
            "tag": "9F26",
            "name": "Application Cryptogram (AC)",
            "format": "binary",
            "length": 8,
            "description": "Cryptogram calculated by the IC card for application verification."
        },
        authority_id=EMVCO_AUTH_ID
    )

    graph.add_rule(
        rule_id="EMV_TAG_9A",
        topic="TAG_DICTIONARY",
        content={
            "tag": "9A",
            "name": "Transaction Date",
            "format": "n 6 (YYMMDD)",
            "length": 3,
            "description": "Local date that transaction was authorized."
        },
        authority_id=EMVCO_AUTH_ID
    )

    graph.add_rule(
        rule_id="EMV_TAG_9C",
        topic="TAG_DICTIONARY",
        content={
            "tag": "9C",
            "name": "Transaction Type",
            "format": "n 2",
            "length": 1,
            "description": "Indicates the type of transaction (e.g. 00=Goods/Services, 01=Cash)."
        },
        authority_id=EMVCO_AUTH_ID
    )

    # APDU Command Rules
    graph.add_rule(
        rule_id="EMV_APDU_SELECT",
        topic="APDU_COMMANDS",
        content={
            "cla": "00",
            "ins": "A4",
            "p1": "04",
            "p2": "00",
            "description": "Select Payment Application by AID"
        },
        authority_id=EMVCO_AUTH_ID
    )

    graph.add_rule(
        rule_id="EMV_APDU_GPO",
        topic="APDU_COMMANDS",
        content={
            "cla": "80",
            "ins": "A8",
            "p1": "00",
            "p2": "00",
            "description": "Get Processing Options"
        },
        authority_id=EMVCO_AUTH_ID
    )

    graph.add_rule(
        rule_id="EMV_APDU_GENERATE_AC",
        topic="APDU_COMMANDS",
        content={
            "cla": "80",
            "ins": "AE",
            "p1": "80", # AAC, ARQC, or TC
            "p2": "00",
            "description": "Generate Application Cryptogram"
        },
        authority_id=EMVCO_AUTH_ID
    )
