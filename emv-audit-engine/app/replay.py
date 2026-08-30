from __future__ import annotations

from typing import Any, Dict

from .canonical import sha256
from .models import TransactionResult
from .orchestrator import DeterministicEMVOrchestrator


class ReplayEngine:

    def __init__(self) -> None:
        self.orchestrator = DeterministicEMVOrchestrator()

    def replay(
        self,
        original: TransactionResult,
    ) -> Dict[str, Any]:

        replayed = self.orchestrator.execute(
            original.request,
            run_id=original.run_id,
        )

        return {
            "run_id": original.run_id,

            "input_equal": (
                original.input_hash ==
                replayed.input_hash
            ),

            "output_equal": (
                original.output_hash ==
                replayed.output_hash
            ),

            "state_equal": (
                original.state ==
                replayed.state
            ),

            "card_equal": (
                original.card.model_dump(mode="json") ==
                replayed.card.model_dump(mode="json")
            ),

            "trace_equal": (
                [
                    x.model_dump(mode="json")
                    for x in original.apdu_trace
                ]
                ==
                [
                    x.model_dump(mode="json")
                    for x in replayed.apdu_trace
                ]
            ),

            "transformations_equal": (
                [
                    x.model_dump(mode="json")
                    for x in original.transformations
                ]
                ==
                [
                    x.model_dump(mode="json")
                    for x in replayed.transformations
                ]
            ),

            "replay": replayed,
        }

    def restate(
        self,
        original: TransactionResult,
    ) -> Dict[str, Any]:

        return {
            "run_id": original.run_id,
            "state": original.state.value,
            "request": original.request.model_dump(mode="json"),
            "card": original.card.model_dump(mode="json"),
            "apdu_trace": [
                x.model_dump(mode="json")
                for x in original.apdu_trace
            ],
            "transformations": [
                x.model_dump(mode="json")
                for x in original.transformations
            ],
            "audit": [
                x.model_dump(mode="json")
                for x in original.audit
            ],
            "input_hash": original.input_hash,
            "output_hash": original.output_hash,
            "deterministic": original.deterministic,
            "replayable": original.replayable,
        }
