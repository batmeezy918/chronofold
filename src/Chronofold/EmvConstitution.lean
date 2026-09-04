import Chronofold.AgdOperators
import Chronofold.AgdIterate
import Chronofold.AgdInvariantSafety
import Chronofold.MasterBidirectionalOperationalClosure
import Chronofold.AgdMaximalConstitutionalOperationalClosure

/-!
# Concrete EMV constitution

Instance of the AGD kernel on the deterministic laboratory
`MachineState` from `batmeezy918/EMV`:

  phase, sequence, optional outcome, optional reason.

This file does not model APDU bytes, TLV, PAN, keys, or cryptograms.
It binds `Omega` / `Covariant` to the public protocol class of that
state machine and classifies the laboratory operators.

Constitution
  Ω  = protocol phase
  C  = outcome class (none / approved / declined / error)

Hidden fibre coordinates (not in the constitution)
  State.id, payload.sequence, payload.reason, event.ruleCount

The TypeScript operator `transition` consults fibre data (sequence
gap, empty rule list). It therefore does not descend through `pi`.
Overlays that touch only fibre coordinates remain admissible.
-/

namespace Chronofold.EMV

open Chronofold.AGD
open Chronofold.MaximalConstitutional

universe u

/-- Laboratory kernel phases, matching `EMVPhase` in
    `src/state-machine/emvStateMachine.ts`. -/
inductive Phase where
  | INIT
  | SELECT
  | GPO
  | READ_RECORD
  | PROCESSING
  | CVM
  | RISK_MANAGEMENT
  | GENERATE_AC
  | COMPLETE
  | FAILED
  deriving DecidableEq, Repr

/-- Terminal outcome class, matching `MachineState.outcome`. -/
inductive Outcome where
  | none
  | approved
  | declined
  | error
  deriving DecidableEq, Repr

/-- Payload of an AGD `State`. `sequence` and `reason` are fibre data. -/
structure EmvPayload where
  phase    : Phase
  sequence : Nat
  outcome  : Outcome
  reason   : Nat
  deriving DecidableEq, Repr

abbrev EmvState := State EmvPayload

def phaseCode : Phase → Nat
  | .INIT             => 0
  | .SELECT           => 1
  | .GPO              => 2
  | .READ_RECORD      => 3
  | .PROCESSING       => 4
  | .CVM              => 5
  | .RISK_MANAGEMENT  => 6
  | .GENERATE_AC      => 7
  | .COMPLETE         => 8
  | .FAILED           => 9

def outcomeCode : Outcome → Nat
  | .none     => 0
  | .approved => 1
  | .declined => 2
  | .error    => 3

/-- Constitutional observable: protocol phase. -/
def Ω : Omega EmvPayload :=
  fun s => phaseCode s.payload.phase

/-- Covariant observable: outcome class. -/
def C : Covariant EmvPayload :=
  fun s => outcomeCode s.payload.outcome

def emvPi : EmvState → QStar EmvPayload Ω C :=
  pi EmvPayload Ω C

def nextPhase : Phase → Phase
  | .INIT            => .SELECT
  | .SELECT          => .GPO
  | .GPO             => .READ_RECORD
  | .READ_RECORD     => .PROCESSING
  | .PROCESSING      => .CVM
  | .CVM             => .RISK_MANAGEMENT
  | .RISK_MANAGEMENT => .GENERATE_AC
  | .GENERATE_AC     => .COMPLETE
  | .COMPLETE        => .COMPLETE
  | .FAILED          => .FAILED

def isTerminal : Phase → Bool
  | .COMPLETE => true
  | .FAILED   => true
  | _         => false

/-! ## Laboratory event (fibre + admission count) -/

inductive Direction where
  | terminalToCard
  | cardToTerminal
  deriving DecidableEq, Repr

/-- Laboratory event. `ruleCount` is the length of `ruleIds`, not the
    rule text. Command / response maps stay off the constitution. -/
structure ProtocolEvent where
  sequence  : Nat
  direction : Direction
  ruleCount : Nat
  deriving DecidableEq, Repr

inductive RejectReason where
  | sequenceGap
  | noAdmissibleTransition
  | terminalState
  deriving DecidableEq, Repr

def reasonCode : RejectReason → Nat
  | .sequenceGap            => 1
  | .noAdmissibleTransition => 2
  | .terminalState          => 3

/-! ## Laboratory operators -/

/-- Hidden-fibre annotation: reason and id may move; constitution may not. -/
def annotate (note : Nat) : Operator EmvPayload :=
  fun s =>
    { id := s.id
      payload := { s.payload with reason := note } }

/-- Sequence counter is fibre data, not constitution. -/
def stampSequence (n : Nat) : Operator EmvPayload :=
  fun s =>
    { s with payload := { s.payload with sequence := n } }

/-- Identity overlay (certificate attach with no field change). -/
def sealOverlay : Operator EmvPayload := id

/-- Protocol advance: changes phase, therefore not admissible. -/
def advance : Operator EmvPayload :=
  fun s =>
    if isTerminal s.payload.phase then s
    else
      { s with payload :=
          { s.payload with
            phase := nextPhase s.payload.phase
            sequence := s.payload.sequence + 1 } }

/-- Fail-closed reject: moves the state into the FAILED / error class. -/
def reject (why : Nat) : Operator EmvPayload :=
  fun s =>
    { s with payload :=
        { s.payload with
          phase := .FAILED
          outcome := .error
          reason := why
          sequence := s.payload.sequence + 1 } }

/-- Matching `reject` in `emvStateMachine.ts`. -/
def failClosed (s : EmvState) (seq : Nat) (why : RejectReason) : EmvState :=
  { s with payload :=
      { phase := .FAILED
        sequence := seq
        outcome := .error
        reason := reasonCode why } }

/-- Matching `transition(state, event)` in `emvStateMachine.ts`.

    Sequence and `ruleCount` are fibre coordinates. The operator is
    therefore not well-defined on the constitutional quotient. -/
def transition (e : ProtocolEvent) : Operator EmvPayload :=
  fun s =>
    if e.sequence == s.payload.sequence + 1 then
      if isTerminal s.payload.phase || e.ruleCount == 0 then
        failClosed s e.sequence .noAdmissibleTransition
      else
        { s with payload :=
            { phase := nextPhase s.payload.phase
              sequence := e.sequence
              outcome := .none
              reason := 0 } }
    else
      failClosed s e.sequence .sequenceGap

/-- Matching `initialState()`. -/
def initial : EmvState :=
  { id := 0
    payload :=
      { phase := .INIT
        sequence := 0
        outcome := .none
        reason := 0 } }

/-! ## Admissibility of overlays -/

theorem annotate_admissible (note : Nat) :
    Admissible EmvPayload Ω C (annotate note) := by
  intro s
  constructor <;> rfl

theorem stampSequence_admissible (n : Nat) :
    Admissible EmvPayload Ω C (stampSequence n) := by
  intro s
  constructor <;> rfl

theorem sealOverlay_admissible :
    Admissible EmvPayload Ω C sealOverlay :=
  admissible_id EmvPayload Ω C

theorem overlay_compose_admissible (note n : Nat) :
    Admissible EmvPayload Ω C (fun s => stampSequence n (annotate note s)) :=
  admissible_compose EmvPayload Ω C (annotate note) (stampSequence n)
    (annotate_admissible note) (stampSequence_admissible n)

/-! ## Injectivity of the constitutional codes -/

theorem phaseCode_inj {p q : Phase} (h : phaseCode p = phaseCode q) : p = q := by
  cases p <;> cases q <;> simp [phaseCode] at h <;> rfl

theorem outcomeCode_inj {a b : Outcome} (h : outcomeCode a = outcomeCode b) : a = b := by
  cases a <;> cases b <;> simp [outcomeCode] at h <;> rfl

/-! ## Advance is well-defined on phase, not admissible -/

theorem advance_wellDefined_phase
    (s₁ s₂ : EmvState)
    (h : Ω s₁ = Ω s₂) :
    Ω (advance s₁) = Ω (advance s₂) := by
  have hp : s₁.payload.phase = s₂.payload.phase :=
    phaseCode_inj h
  unfold advance Ω
  cases hterm : isTerminal s₁.payload.phase
  · have hterm₂ : isTerminal s₂.payload.phase = false := by
      simpa [hp] using hterm
    simp [hterm₂, hp]
  · have hterm₂ : isTerminal s₂.payload.phase = true := by
      simpa [hp] using hterm
    simp [hterm₂, hp]

theorem advance_not_always_admissible :
    ¬ (∀ s : EmvState, Ω (advance s) = Ω s) := by
  intro h
  have hΩ := h initial
  simp [advance, Ω, phaseCode, isTerminal, nextPhase, initial] at hΩ

theorem reject_changes_constitution (s : EmvState)
    (hphase : s.payload.phase ≠ .FAILED) :
    Ω (reject 1 s) ≠ Ω s ∨ C (reject 1 s) ≠ C s := by
  left
  intro heq
  have hf : s.payload.phase = .FAILED :=
    (phaseCode_inj heq).symm
  exact hphase hf

/-! ## Event transition: fibre-sensitive, not a descent -/

def stepEvent : ProtocolEvent :=
  { sequence := 1, direction := .terminalToCard, ruleCount := 1 }

def lateInit : EmvState :=
  { id := 1
    payload :=
      { phase := .INIT
        sequence := 5
        outcome := .none
        reason := 0 } }

theorem initial_late_same_class :
    emvPi initial = emvPi lateInit :=
  Quotient.sound ⟨rfl, rfl⟩

theorem transition_not_wellDefined :
    ¬ MaximalConstitutional.WellDefined emvPi (transition stepEvent) := by
  intro hWD
  have hπ : emvPi initial = emvPi lateInit := initial_late_same_class
  have himg : emvPi (transition stepEvent initial) =
      emvPi (transition stepEvent lateInit) :=
    hWD initial lateInit hπ
  have hexact : Ω (transition stepEvent initial) =
      Ω (transition stepEvent lateInit) :=
    (Quotient.exact himg).1
  simp [transition, stepEvent, initial, lateInit, failClosed, Ω,
        phaseCode, isTerminal, nextPhase] at hexact

theorem transition_not_admissible :
    ¬ Admissible EmvPayload Ω C (transition stepEvent) := by
  intro hT
  have hΩ : Ω (transition stepEvent initial) = Ω initial := (hT initial).1
  simp [transition, stepEvent, initial, Ω, phaseCode, isTerminal, nextPhase] at hΩ

theorem accepted_step_changes_phase :
    Ω (transition stepEvent initial) = phaseCode .SELECT := by
  simp [transition, stepEvent, initial, Ω, phaseCode, isTerminal, nextPhase]

theorem sequence_gap_is_failed :
    (transition { sequence := 0, direction := .terminalToCard, ruleCount := 1 }
      initial).payload.phase = .FAILED := by
  simp [transition, initial, failClosed]

/-! ## Critical predicates that factor through the constitution -/

def criticalFailed : EmvState → Prop :=
  fun s => s.payload.phase = .FAILED

def criticalApproved : EmvState → Prop :=
  fun s => s.payload.outcome = .approved

theorem criticalFailed_factors
    {s₁ s₂ : EmvState} (h : Ω s₁ = Ω s₂) :
    criticalFailed s₁ ↔ criticalFailed s₂ := by
  have hp : s₁.payload.phase = s₂.payload.phase := phaseCode_inj h
  simp [criticalFailed, hp]

theorem criticalApproved_factors
    {s₁ s₂ : EmvState} (h : C s₁ = C s₂) :
    criticalApproved s₁ ↔ criticalApproved s₂ := by
  have ho : s₁.payload.outcome = s₂.payload.outcome := outcomeCode_inj h
  simp [criticalApproved, ho]

theorem overlay_preserves_failed (note : Nat) :
    ∀ s, criticalFailed s → criticalFailed (annotate note s) := by
  intro s hf
  simpa [annotate, criticalFailed] using hf

theorem overlay_preserves_approved (n : Nat) :
    ∀ s, criticalApproved s → criticalApproved (stampSequence n s) := by
  intro s hf
  simpa [stampSequence, criticalApproved] using hf

/-- Failed is a constitutional critical: it is exactly `Ω = 9`. -/
theorem failed_is_omega_level (s : EmvState) :
    criticalFailed s ↔ Ω s = 9 := by
  constructor
  · intro h
    have hp : s.payload.phase = .FAILED := h
    simp [Ω, phaseCode, hp]
  · intro h
    have : phaseCode s.payload.phase = phaseCode .FAILED := by
      simpa [Ω, phaseCode] using h
    exact phaseCode_inj this

theorem criticalFailed_factors_pi :
    CriticalFactors emvPi criticalFailed := by
  intro s₁ s₂ h
  exact criticalFailed_factors (Quotient.exact h).1

theorem criticalApproved_factors_pi :
    CriticalFactors emvPi criticalApproved := by
  intro s₁ s₂ h
  exact criticalApproved_factors (Quotient.exact h).2

theorem annotate_safe_failed (note : Nat) :
    Safe criticalFailed (annotate note) :=
  overlay_preserves_failed note

theorem stamp_safe_approved (n : Nat) :
    Safe criticalApproved (stampSequence n) :=
  overlay_preserves_approved n

theorem annotate_safe_failed_from_factors (note : Nat) :
    Safe criticalFailed (annotate note) :=
  admissible_preserves_safe emvPi
    ((agd_admissible_iff_abstract EmvPayload Ω C (annotate note)).mp
      (annotate_admissible note))
    criticalFailed_factors_pi

theorem annotate_iterate_safe_failed (note : Nat) :
    Safe criticalFailed (iterate (annotate note) 3) :=
  safe_iterate (annotate_safe_failed_from_factors note) 3

theorem invariantSafe_emv_phase_and_outcome :
    invariantSafe EmvPayload Ω C [Ω, C] :=
  invariantSafe_omega_and_C EmvPayload Ω C

/-! ## Master and maximal packages on the EMV constitution -/

theorem emv_master_closure (T : Operator EmvPayload) :
    ((∀ s, emvPi (T s) = emvPi s) ↔ Admissible EmvPayload Ω C T)
    ∧
    (∀ hT : Admissible EmvPayload Ω C T,
      ∀ s, TBar EmvPayload Ω C T hT (emvPi s) = emvPi (T s))
    ∧
    (∀ q : QStar EmvPayload Ω C, ∃ s : EmvState, emvPi s = q)
    ∧
    invariantSafe EmvPayload Ω C [Ω, C] := by
  refine ⟨?iff, ?sound, ?recon, ?safe⟩
  · exact admissible_iff_class_eq EmvPayload Ω C T
  · intro hT s
    exact TBar_sound EmvPayload Ω C T hT s
  · intro q
    exact exists_reconstruct EmvPayload Ω C q
  · exact invariantSafe_emv_phase_and_outcome

theorem emv_maximal_abstract :
    OperationalEquivalence emvPi ∧
    BidirectionalAdmissibility emvPi ∧
    QuotientExecution emvPi ∧
    IterativeClosure emvPi ∧
    Reconstruction emvPi ∧
    ObservableFactorization emvPi ∧
    CompositionClosure emvPi ∧
    SafetyPreservation emvPi :=
  MaximalConstitutional.maximal_constitutional_operational_closure emvPi

theorem emv_agd_maximal (T : Operator EmvPayload) :
    OperationalEquivalence emvPi ∧
    BidirectionalAdmissibility emvPi ∧
    QuotientExecution emvPi ∧
    IterativeClosure emvPi ∧
    Reconstruction emvPi ∧
    ObservableFactorization emvPi ∧
    CompositionClosure emvPi ∧
    SafetyPreservation emvPi ∧
    ((∀ s, emvPi (T s) = emvPi s) ↔ Admissible EmvPayload Ω C T) ∧
    (∀ hT : Admissible EmvPayload Ω C T,
      ∀ s, TBar EmvPayload Ω C T hT (emvPi s) = emvPi (T s)) ∧
    (∀ hT : Admissible EmvPayload Ω C T,
      ∀ n s,
        TBar EmvPayload Ω C (opIterate EmvPayload T n)
          (admissible_iterate EmvPayload Ω C T hT n)
          (emvPi s) =
        emvPi (opIterate EmvPayload T n s)) ∧
    (∀ q : QStar EmvPayload Ω C, ∃ s : EmvState, emvPi s = q) ∧
    invariantSafe EmvPayload Ω C [Ω, C] :=
  Chronofold.AGD.maximal_constitutional_operational_closure EmvPayload Ω C T

theorem emv_overlays_closed (note n : Nat) :
    Admissible EmvPayload Ω C (annotate note) ∧
    Admissible EmvPayload Ω C (stampSequence n) ∧
    Admissible EmvPayload Ω C sealOverlay ∧
    Admissible EmvPayload Ω C
      (opIterate EmvPayload (annotate note) 3) := by
  refine ⟨annotate_admissible note,
          stampSequence_admissible n,
          sealOverlay_admissible, ?_⟩
  exact admissible_iterate EmvPayload Ω C (annotate note)
    (annotate_admissible note) 3

/-- Quotient execution of an admissible overlay is the identity on `Q*`. -/
theorem emv_overlay_TBar_is_id
    (note : Nat)
    (hT : Admissible EmvPayload Ω C (annotate note))
    (s : EmvState) :
    TBar EmvPayload Ω C (annotate note) hT (emvPi s) = emvPi s := by
  have h := TBar_sound EmvPayload Ω C (annotate note) hT s
  have hπ : emvPi (annotate note s) = emvPi s :=
    Quotient.sound ⟨(hT s).1, (hT s).2⟩
  exact h.trans hπ

end Chronofold.EMV
