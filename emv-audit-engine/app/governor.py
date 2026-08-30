from __future__ import annotations

from copy import deepcopy
from typing import Any, Dict, List

from .canonical import sha256
from .models import Transformation


class DeterministicGovernor:

    def __init__(self) -> None:
        self.registry: List[Transformation] = []

    def transform(
        self,
        field_ref: str,
        operation: str,
        input_value: Any,
        output_value: Any,
        rule: str,
    ) -> Any:

        sequence = len(self.registry) + 1

        transformation = Transformation(
            sequence=sequence,
            field_ref=field_ref,
            operation=operation,
            input_value=input_value,
            output_value=output_value,
            input_hash=sha256(input_value),
            output_hash=sha256(output_value),
            deterministic=True,
            rule=rule,
        )

        self.registry.append(transformation)

        return output_value

    def clear(self) -> None:
        self.registry.clear()
