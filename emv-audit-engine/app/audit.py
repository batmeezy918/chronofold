from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Dict, List

from .canonical import hash_chain, sha256
from .models import AuditEvent

DETERMINISTIC_EPOCH = datetime(2026, 1, 1, 0, 0, 0, tzinfo=timezone.utc)


class AuditLedger:

    def __init__(self) -> None:
        self.events: List[AuditEvent] = []

    @property
    def tip(self) -> str:
        if not self.events:
            return "GENESIS"

        return self.events[-1].event_hash

    def append(
        self,
        event_type: str,
        state_before: str,
        state_after: str,
        input_value: Any,
        output_value: Any,
        data: Dict[str, Any] | None = None,
        timestamp: datetime | None = None,
    ) -> AuditEvent:

        sequence = len(self.events) + 1

        input_hash = sha256(input_value)
        output_hash = sha256(output_value)

        event_id = sha256({
            "sequence": sequence,
            "event_type": event_type,
            "input_hash": input_hash,
            "output_hash": output_hash,
        })[:32]

        event_body = {
            "sequence": sequence,
            "event_id": event_id,
            "event_type": event_type,
            "state_before": state_before,
            "state_after": state_after,
            "input_hash": input_hash,
            "output_hash": output_hash,
            "previous_event_hash": self.tip,
            "data": data or {},
        }

        event_hash = hash_chain(
            self.tip,
            event_body,
        )

        event = AuditEvent(
            sequence=sequence,
            event_id=event_id,
            timestamp=timestamp or DETERMINISTIC_EPOCH,
            event_type=event_type,
            state_before=state_before,
            state_after=state_after,
            input_hash=input_hash,
            output_hash=output_hash,
            previous_event_hash=self.tip,
            event_hash=event_hash,
            data=data or {},
        )

        self.events.append(event)

        return event

    def verify(self) -> bool:
        previous = "GENESIS"

        for event in self.events:
            body = {
                "sequence": event.sequence,
                "event_id": event.event_id,
                "event_type": event.event_type,
                "state_before": event.state_before,
                "state_after": event.state_after,
                "input_hash": event.input_hash,
                "output_hash": event.output_hash,
                "previous_event_hash": event.previous_event_hash,
                "data": event.data,
            }

            expected = hash_chain(previous, body)

            if event.previous_event_hash != previous:
                return False

            if event.event_hash != expected:
                return False

            previous = event.event_hash

        return True
