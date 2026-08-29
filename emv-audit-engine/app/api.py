from __future__ import annotations

from typing import Any, Dict

from fastapi import FastAPI, HTTPException

from .experiments import ExperimentEngine
from .models import ExperimentRequest, PaymentRequest
from .orchestrator import DeterministicEMVOrchestrator


app = FastAPI(
    title="Deterministic EMV Audit Engine",
    version="1.0.0",
)

orchestrator = DeterministicEMVOrchestrator()
experiments = ExperimentEngine()

RUNS: Dict[str, Any] = {}


@app.get("/health")
def health():
    return {
        "ok": True,
        "service": "deterministic-emv-audit-engine",
        "version": "1.0.0",
        "live_network": False,
        "synthetic_only": True,
    }


@app.post("/v1/transactions")
def create_transaction(request: PaymentRequest):

    try:
        result = orchestrator.execute(request)

        RUNS[result.run_id] = result

        return result.model_dump(mode="json")

    except Exception as exc:
        raise HTTPException(
            status_code=400,
            detail=str(exc),
        )


@app.get("/v1/transactions/{run_id}")
def get_transaction(run_id: str):

    result = RUNS.get(run_id)

    if result is None:
        raise HTTPException(
            status_code=404,
            detail="Run not found",
        )

    return result.model_dump(mode="json")


@app.post("/v1/experiments")
def run_experiment(request: ExperimentRequest):

    try:
        result = experiments.run(request)

        for variation in result.results:
            if variation.run_id in RUNS:
                continue

        return result.model_dump(mode="json")

    except Exception as exc:
        raise HTTPException(
            status_code=400,
            detail=str(exc),
        )


@app.post("/v1/transactions/{run_id}/replay")
def replay_transaction(run_id: str):

    result = RUNS.get(run_id)

    if result is None:
        raise HTTPException(
            status_code=404,
            detail="Run not found",
        )

    from .replay import ReplayEngine

    engine = ReplayEngine()

    replay = engine.replay(result)

    return {
        "run_id": run_id,
        "input_equal": replay["input_equal"],
        "output_equal": replay["output_equal"],
        "state_equal": replay["state_equal"],
        "card_equal": replay["card_equal"],
        "trace_equal": replay["trace_equal"],
        "transformations_equal": replay[
            "transformations_equal"
        ],
    }


@app.get("/v1/transactions/{run_id}/restate")
def restate_transaction(run_id: str):

    result = RUNS.get(run_id)

    if result is None:
        raise HTTPException(
            status_code=404,
            detail="Run not found",
        )

    from .replay import ReplayEngine

    return ReplayEngine().restate(result)
