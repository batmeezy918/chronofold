import Chronofold.AgdOperators
import Chronofold.AgdIterate
import Chronofold.AgdInvariantSafety
import Chronofold.MasterBidirectionalOperationalClosure
import Chronofold.AgdMaximalConstitutionalOperationalClosure

namespace Chronofold.EMVStandalone

open Chronofold.AGD
open Chronofold.MaximalConstitutional

inductive Phase where
  | INIT | SELECT | GPO | READ_RECORD | PROCESSING | CVM
  | RISK_MANAGEMENT | GENERATE_AC | COMPLETE | FAILED
  deriving DecidableEq, Repr

inductive Outcome where
  | none | approved | declined | error
  deriving DecidableEq, Repr

structure EmvPayload where
  phase : Phase
  sequence : Nat
  outcome : Outcome
  reason : Nat
  deriving DecidableEq, Repr

abbrev EmvState := State EmvPayload

def phaseCode : Phase → Nat
  | .INIT => 0 | .SELECT => 1 | .GPO => 2 | .READ_RECORD => 3
  | .PROCESSING => 4 | .CVM => 5 | .RISK_MANAGEMENT => 6
  | .GENERATE_AC => 7 | .COMPLETE => 8 | .FAILED => 9

def outcomeCode : Outcome → Nat
  | .none => 0 | .approved => 1 | .declined => 2 | .error => 3

def Ω : Omega EmvPayload := fun s => phaseCode s.payload.phase
def C : Covariant EmvPayload := fun s => outcomeCode s.payload.outcome

def emvPi : EmvState → QStar EmvPayload Ω C := pi EmvPayload Ω C

def annotate (note : Nat) : Operator EmvPayload :=
  fun s => { s with payload := { s.payload with reason := note } }

def stampSequence (n : Nat) : Operator EmvPayload :=
  fun s => { s with payload := { s.payload with sequence := n } }

def sealOverlay : Operator EmvPayload := id

theorem phaseCode_inj {p q : Phase} (h : phaseCode p = phaseCode q) : p = q := by
  cases p <;> cases q <;> simp [phaseCode] at h <;> rfl

theorem outcomeCode_inj {a b : Outcome} (h : outcomeCode a = outcomeCode b) : a = b := by
  cases a <;> cases b <;> simp [outcomeCode] at h <;> rfl

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

def criticalFailed : EmvState → Prop := fun s => s.payload.phase = .FAILED
def criticalApproved : EmvState → Prop := fun s => s.payload.outcome = .approved

theorem criticalFailed_factors {s₁ s₂ : EmvState} (h : Ω s₁ = Ω s₂) :
    criticalFailed s₁ ↔ criticalFailed s₂ := by
  have hp : s₁.payload.phase = s₂.payload.phase := phaseCode_inj h
  simp [criticalFailed, hp]

theorem criticalApproved_factors {s₁ s₂ : EmvState} (h : C s₁ = C s₂) :
    criticalApproved s₁ ↔ criticalApproved s₂ := by
  have ho : s₁.payload.outcome = s₂.payload.outcome := outcomeCode_inj h
  simp [criticalApproved, ho]

end Chronofold.EMVStandalone
