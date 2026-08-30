from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, ConfigDict, Field


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


class Provenance(str, Enum):
    SYNTHETIC = "synthetic"
    DERIVED = "derived"
    OBSERVED = "observed"


class TransactionState(str, Enum):
    CREATED = "created"
    CARD_SELECTED = "card_selected"
    APDU_BUILT = "apdu_built"
    AUTHORIZATION_REQUESTED = "authorization_requested"
    AUTHORIZED = "authorized"
    CAPTURED = "captured"
    VOIDED = "voided"
    REFUNDED = "refunded"
    FAILED = "failed"


class CardProfile(BaseModel):
    model_config = ConfigDict(extra="forbid")

    profile_id: str
    scheme: str
    network_family: str

    # Synthetic only.
    pan_prefix: str
    pan_length: int = 16

    expiry_month: int = 12
    expiry_year: int = 30

    cardholder_name: str = "TEST USER"
    service_code: str = "201"

    # Anchored BIN issuer & region metadata
    issuer_name: str = "GENERIC TEST ISSUER"
    issuing_country_name: str = "UNITED STATES"
    region_name: str = "NORTH AMERICA"
    country: str = "US"
    currency: str = "USD"
    card_type: str = "CREDIT"  # CREDIT, DEBIT, PREPAID

    provenance: Provenance = Provenance.SYNTHETIC


class SyntheticCard(BaseModel):
    model_config = ConfigDict(extra="forbid")

    card_id: str
    profile_id: str

    scheme: str
    pan: str
    masked_pan: str

    expiry_month: int
    expiry_year: int

    cardholder_name: str
    service_code: str

    # Anchored BIN issuer & region metadata
    issuer_name: str
    issuing_country_name: str
    region_name: str
    country: str
    currency: str
    card_type: str

    synthetic: bool = True
    provenance: Provenance = Provenance.DERIVED

    # Visible correlation fields.
    display: Dict[str, Any] = Field(default_factory=dict)


class PaymentRequest(BaseModel):
    model_config = ConfigDict(extra="allow")

    amount: int = Field(default=1000, ge=0)
    currency: str = Field(default="USD", min_length=3, max_length=3)

    card_profile: Optional[str] = "visa-test"
    pan: Optional[str] = None

    merchant_id: str = "TEST-MERCHANT-001"
    terminal_id: str = "TEST-TERMINAL-001"

    capture: bool = False

    metadata: Dict[str, Any] = Field(default_factory=dict)


class APDUFrame(BaseModel):
    seq: int
    direction: str
    command: str
    response: str = ""
    status_word: str = ""
    meaning: str = ""

    provenance: Provenance = Provenance.SYNTHETIC


class Transformation(BaseModel):
    sequence: int
    field_ref: str
    operation: str

    input_value: Any
    output_value: Any

    input_hash: str
    output_hash: str

    deterministic: bool = True
    rule: str = ""


class AuditEvent(BaseModel):
    sequence: int
    event_id: str

    timestamp: datetime

    event_type: str
    state_before: str
    state_after: str

    input_hash: str
    output_hash: str

    previous_event_hash: str
    event_hash: str

    data: Dict[str, Any] = Field(default_factory=dict)


class TransactionResult(BaseModel):
    run_id: str

    state: TransactionState

    card: SyntheticCard

    request: PaymentRequest

    apdu_trace: List[APDUFrame]
    transformations: List[Transformation]
    audit: List[AuditEvent]

    input_hash: str
    output_hash: str

    deterministic: bool
    replayable: bool

    authorization_code: str
    response_code: str


class Variation(BaseModel):
    path: str
    value: Any


class ExperimentRequest(BaseModel):
    baseline: PaymentRequest
    variations: List[Variation] = Field(min_length=1, max_length=200)


class VariationResult(BaseModel):
    variation_no: int
    mutation: Variation

    run_id: str

    baseline_output_hash: str
    output_hash: str

    changed: bool
    deterministic: bool

    state: TransactionState

    audit_event_count: int
    transformation_count: int


class ExperimentResult(BaseModel):
    experiment_id: str

    variation_count: int
    deterministic_count: int
    changed_count: int

    results: List[VariationResult]

    experiment_hash: str
