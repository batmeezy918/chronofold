from __future__ import annotations

import copy
from typing import Any, Dict

from .canonical import sha256
from .models import (
    ExperimentRequest,
    ExperimentResult,
    PaymentRequest,
    VariationResult,
)
from .orchestrator import DeterministicEMVOrchestrator


def set_path(
    target: Dict[str, Any],
    path: str,
    value: Any,
) -> None:

    parts = path.split(".")

    current = target

    for part in parts[:-1]:
        if part not in current:
            current[part] = {}

        if not isinstance(current[part], dict):
            raise ValueError(
                f"Cannot descend through non-object field: {part}"
            )

        current = current[part]

    current[parts[-1]] = value


class ExperimentEngine:

    MAX_VARIATIONS = 200

    def __init__(self) -> None:
        self.orchestrator = DeterministicEMVOrchestrator()

    def run(
        self,
        experiment: ExperimentRequest,
    ) -> ExperimentResult:

        if len(experiment.variations) > self.MAX_VARIATIONS:
            raise ValueError(
                f"Maximum {self.MAX_VARIATIONS} variations"
            )

        baseline = self.orchestrator.execute(
            experiment.baseline,
        )

        results = []

        for index, variation in enumerate(
            experiment.variations,
            start=1,
        ):

            mutated = experiment.baseline.model_dump(
                mode="json"
            )

            set_path(
                mutated,
                variation.path,
                variation.value,
            )

            request = PaymentRequest.model_validate(mutated)

            run = self.orchestrator.execute(
                request,
            )

            results.append(
                VariationResult(
                    variation_no=index,
                    mutation=variation,
                    run_id=run.run_id,
                    baseline_output_hash=baseline.output_hash,
                    output_hash=run.output_hash,
                    changed=(
                        baseline.output_hash !=
                        run.output_hash
                    ),
                    deterministic=run.deterministic,
                    state=run.state,
                    audit_event_count=len(run.audit),
                    transformation_count=len(run.transformations),
                )
            )

        experiment_hash = sha256({
            "baseline": baseline.output_hash,
            "results": [
                result.model_dump(mode="json")
                for result in results
            ],
        })

        return ExperimentResult(
            experiment_id=experiment_hash[:32],
            variation_count=len(results),
            deterministic_count=sum(
                1 for x in results
                if x.deterministic
            ),
            changed_count=sum(
                1 for x in results
                if x.changed
            ),
            results=results,
            experiment_hash=experiment_hash,
        )
