from __future__ import annotations

import copy
from typing import Any, Dict

from .audit import AuditLedger
from .card import build_card
from .canonical import sha256
from .emv import build_trace
from .governor import DeterministicGovernor
from .models import (
    PaymentRequest,
    TransactionResult,
    TransactionState,
)


class DeterministicEMVOrchestrator:

    VERSION = "1.0.0"

    def execute(
        self,
        request: PaymentRequest,
        run_id: str | None = None,
    ) -> TransactionResult:

        if run_id is None:
            run_id = sha256({
                "request": request.model_dump(mode="json"),
                "version": self.VERSION,
            })[:32]

        governor = DeterministicGovernor()
        ledger = AuditLedger()

        request_hash = sha256(request)

        ledger.append(
            event_type="REQUEST_CREATED",
            state_before="none",
            state_after=TransactionState.CREATED.value,
            input_value=request.model_dump(mode="json"),
            output_value=request.model_dump(mode="json"),
            data={
                "orchestrator_version": self.VERSION,
            },
        )

        card = build_card(
            profile_id=request.card_profile,
            partial_pan=request.pan,
            seed=run_id,
        )

        governor.transform(
            field_ref="card.pan",
            operation="complete_synthetic_pan",
            input_value=request.pan,
            output_value=card.pan,
            rule="deterministic synthetic completion + Luhn",
        )

        ledger.append(
            event_type="CARD_SELECTED",
            state_before=TransactionState.CREATED.value,
            state_after=TransactionState.CARD_SELECTED.value,
            input_value=request.pan,
            output_value=card.model_dump(mode="json"),
            data={
                "synthetic": True,
                "scheme": card.scheme,
                "card_id": card.card_id,
                "issuer_name": card.issuer_name,
                "issuing_country_name": card.issuing_country_name,
                "region_name": card.region_name,
                "country": card.country,
                "currency": card.currency,
                "card_type": card.card_type,
            },
        )

        trace = build_trace(card)

        governor.transform(
            field_ref="emv.apdu_trace",
            operation="build_apdu_sequence",
            input_value=card.model_dump(mode="json"),
            output_value=[
                frame.model_dump(mode="json")
                for frame in trace
            ],
            rule="synthetic EMV fixture state machine",
        )

        ledger.append(
            event_type="APDU_TRACE_BUILT",
            state_before=TransactionState.CARD_SELECTED.value,
            state_after=TransactionState.APDU_BUILT.value,
            input_value=card.model_dump(mode="json"),
            output_value=[
                frame.model_dump(mode="json")
                for frame in trace
            ],
        )

        authorization_input = {
            "amount": request.amount,
            "currency": request.currency.upper(),
            "merchant_id": request.merchant_id,
            "terminal_id": request.terminal_id,
            "card_profile": card.profile_id,
            "issuer_name": card.issuer_name,
            "issuing_country": card.issuing_country_name,
        }

        authorization_code = sha256({
            "run_id": run_id,
            "authorization": authorization_input,
        })[:6].upper()

        authorization = {
            "response_code": "00",
            "authorization_code": authorization_code,
            "approved": True,
            "capture": request.capture,
        }

        governor.transform(
            field_ref="authorization.request",
            operation="normalize_authorization",
            input_value=authorization_input,
            output_value=authorization_input,
            rule="canonical field ordering and normalization",
        )

        governor.transform(
            field_ref="authorization.response",
            operation="interpret_authorization",
            input_value=authorization,
            output_value=authorization,
            rule="deterministic synthetic authorization rule",
        )

        ledger.append(
            event_type="AUTHORIZATION",
            state_before=TransactionState.APDU_BUILT.value,
            state_after=TransactionState.AUTHORIZED.value,
            input_value=authorization_input,
            output_value=authorization,
            data={
                "connector": "synthetic-deterministic",
                "live_network": False,
            },
        )

        final_state = (
            TransactionState.CAPTURED
            if request.capture
            else TransactionState.AUTHORIZED
        )

        if request.capture:
            ledger.append(
                event_type="CAPTURE",
                state_before=TransactionState.AUTHORIZED.value,
                state_after=TransactionState.CAPTURED.value,
                input_value=authorization,
                output_value={
                    "captured": True,
                    "amount": request.amount,
                    "currency": request.currency.upper(),
                },
            )

        input_hash = sha256({
            "request": request.model_dump(mode="json"),
            "card": card.model_dump(mode="json"),
        })

        output_hash = sha256({
            "state": final_state.value,
            "card": card.model_dump(mode="json"),
            "trace": [
                frame.model_dump(mode="json")
                for frame in trace
            ],
            "transformations": [
                transformation.model_dump(mode="json")
                for transformation in governor.registry
            ],
            "audit": [
                event.model_dump(mode="json")
                for event in ledger.events
            ],
            "authorization": authorization,
        })

        if not ledger.verify():
            raise RuntimeError("Audit ledger invariant violated")

        return TransactionResult(
            run_id=run_id,
            state=final_state,
            card=card,
            request=request,
            apdu_trace=trace,
            transformations=governor.registry,
            audit=ledger.events,
            input_hash=input_hash,
            output_hash=output_hash,
            deterministic=True,
            replayable=True,
            authorization_code=authorization_code,
            response_code="00",
        )
