from app.card import build_card, luhn_valid
from app.experiments import ExperimentEngine
from app.models import ExperimentRequest, PaymentRequest, Variation
from app.orchestrator import DeterministicEMVOrchestrator
from app.replay import ReplayEngine
from app.tlv import encode_tlv, parse_tlv
from fastapi.testclient import TestClient
from app.api import app


def test_synthetic_card_is_16_digits():
    request = PaymentRequest(
        card_profile="visa-test",
        pan="411111",
    )

    result = DeterministicEMVOrchestrator().execute(request)

    assert len(result.card.pan) == 16
    assert result.card.pan.startswith("411111")
    assert luhn_valid(result.card.pan)
    assert result.card.synthetic is True


def test_bin_metadata_resolution():
    # Visa Chase US
    res_chase = DeterministicEMVOrchestrator().execute(
        PaymentRequest(pan="454313")
    )
    assert res_chase.card.issuer_name == "JPMORGAN CHASE BANK N.A."
    assert res_chase.card.issuing_country_name == "UNITED STATES"
    assert res_chase.card.country == "US"
    assert res_chase.card.currency == "USD"

    # Visa Barclays UK
    res_barclays = DeterministicEMVOrchestrator().execute(
        PaymentRequest(pan="465858")
    )
    assert res_barclays.card.issuer_name == "BARCLAYS BANK PLC"
    assert res_barclays.card.issuing_country_name == "UNITED KINGDOM"
    assert res_barclays.card.country == "GB"
    assert res_barclays.card.currency == "GBP"

    # Mastercard 2-Series
    res_mc2 = DeterministicEMVOrchestrator().execute(
        PaymentRequest(pan="222100")
    )
    assert res_mc2.card.scheme == "MASTERCARD"
    assert res_mc2.card.issuer_name == "MASTERCARD 2-SERIES TEST ISSUER"

    # AmEx UK
    res_amex = DeterministicEMVOrchestrator().execute(
        PaymentRequest(pan="374242")
    )
    assert res_amex.card.scheme == "AMERICAN_EXPRESS"
    assert len(res_amex.card.pan) == 15
    assert res_amex.card.issuing_country_name == "UNITED KINGDOM"


def test_same_input_same_output():
    request = PaymentRequest(
        amount=1000,
        currency="USD",
        card_profile="visa-test",
        pan="412345",
    )

    engine = DeterministicEMVOrchestrator()

    a = engine.execute(
        request,
        run_id="fixed-run",
    )

    b = engine.execute(
        request,
        run_id="fixed-run",
    )

    assert a.input_hash == b.input_hash
    assert a.output_hash == b.output_hash
    assert a.card.pan == b.card.pan


def test_replay_is_exact():
    request = PaymentRequest(
        amount=1099,
        currency="USD",
        card_profile="mastercard-test",
        pan="512345",
    )

    engine = DeterministicEMVOrchestrator()

    original = engine.execute(
        request,
        run_id="replay-test",
    )

    replay = ReplayEngine().replay(original)

    assert replay["input_equal"] is True
    assert replay["output_equal"] is True
    assert replay["state_equal"] is True
    assert replay["card_equal"] is True
    assert replay["trace_equal"] is True
    assert replay["transformations_equal"] is True


def test_bulk_200():
    baseline = PaymentRequest(
        amount=1000,
        currency="USD",
        card_profile="visa-test",
        pan="412345",
    )

    variations = [
        Variation(
            path="amount",
            value=1000 + i,
        )
        for i in range(200)
    ]

    result = ExperimentEngine().run(
        ExperimentRequest(
            baseline=baseline,
            variations=variations,
        )
    )

    assert result.variation_count == 200
    assert result.deterministic_count == 200


def test_audit_chain():
    request = PaymentRequest(
        card_profile="amex-test",
        pan="371234",
    )

    result = DeterministicEMVOrchestrator().execute(
        request,
        run_id="audit-test",
    )

    from app.audit import AuditLedger

    ledger = AuditLedger()

    for event in result.audit:
        ledger.events.append(event)

    assert ledger.verify() is True


def test_tlv_parser_and_encoder():
    encoded = encode_tlv("9F02", "000000001000")
    assert encoded == "9F0206000000001000"

    tlv_list = parse_tlv(encoded)
    assert len(tlv_list) == 1
    assert tlv_list[0].tag == "9F02"
    assert tlv_list[0].length == 6
    assert tlv_list[0].value == "000000001000"


def test_api_endpoints():
    client = TestClient(app)

    # Health
    health_res = client.get("/health")
    assert health_res.status_code == 200
    assert health_res.json()["ok"] is True

    # Create Transaction
    tx_res = client.post(
        "/v1/transactions",
        json={
            "amount": 2500,
            "currency": "USD",
            "pan": "454313",
        },
    )
    assert tx_res.status_code == 200
    data = tx_res.json()
    run_id = data["run_id"]
    assert data["card"]["issuer_name"] == "JPMORGAN CHASE BANK N.A."

    # Get Transaction
    get_res = client.get(f"/v1/transactions/{run_id}")
    assert get_res.status_code == 200
    assert get_res.json()["run_id"] == run_id

    # Replay Transaction
    replay_res = client.post(f"/v1/transactions/{run_id}/replay")
    assert replay_res.status_code == 200
    assert replay_res.json()["output_equal"] is True

    # Restate Transaction
    restate_res = client.get(f"/v1/transactions/{run_id}/restate")
    assert restate_res.status_code == 200
    assert restate_res.json()["run_id"] == run_id
