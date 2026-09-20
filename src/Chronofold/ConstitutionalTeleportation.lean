import Chronofold.AgdMaximalConstitutionalOperationalClosure
import Chronofold.EmvConstitution

/-!
# Constitutional Teleportation

Lean 4 core only. No unfinished goals. No placeholder predicates.

Spine
  π : X → Q
  R : Q → X
  TEL := R ∘ π

Sufficient assumptions, kept separate:

  Section        π ∘ R = id_Q
  Intertwining   π ∘ T = TQ ∘ π
  Factorization  O = OBar ∘ π   (same shape for decisions)

Section alone gives TEL² = TEL and π(TEL x) = π x.
Trajectory preservation requires intertwining.
Observable / decision preservation requires factorization.

The skeleton's `Function.LeftInverse R π` is *not* a section:
that identity is R ∘ π = id_X and collapses every fibre.
This module uses the correct section `π ∘ R = id_Q`.

Operational reading: reconstruct once, then run TQ on Q.
Do not reconstruct twice. Do not ask Lean to prove runtime.
-/

universe u v w

namespace Chronofold.ConstitutionalTeleportation

variable {X : Type u} {Q : Type v}

/-! ## 0. Operators and iteration -/

def iterate {α : Type _} (T : α → α) : Nat → α → α
  | 0,     x => x
  | n + 1, x => T (iterate T n x)

theorem iterate_zero {α : Type _} (T : α → α) (x : α) :
    iterate T 0 x = x :=
  rfl

theorem iterate_succ {α : Type _} (T : α → α) (n : Nat) (x : α) :
    iterate T (n + 1) x = T (iterate T n x) :=
  rfl

def Idempotent {α : Type _} (f : α → α) : Prop :=
  ∀ x, f (f x) = f x

/-! ## 1. Section vs retract (do not conflate) -/

/-- Correct section: every class reconstructs to itself. -/
def Section (π : X → Q) (R : Q → X) : Prop :=
  ∀ q : Q, π (R q) = q

/-- Fibre collapse: reconstruction inverts projection on X.
    This is *not* assumed and is not needed for teleportation. -/
def Retract (π : X → Q) (R : Q → X) : Prop :=
  ∀ x : X, R (π x) = x

theorem section_iff_comp_id (π : X → Q) (R : Q → X) :
    Section π R ↔ π ∘ R = id := by
  constructor
  · intro h
    funext q
    exact h q
  · intro h q
    exact congrFun h q

theorem retract_implies_injective_pi
    (π : X → Q) (R : Q → X) (h : Retract π R)
    {x y : X} (heq : π x = π y) : x = y := by
  calc
    x = R (π x) := (h x).symm
    _ = R (π y) := by rw [heq]
    _ = y       := h y

/-! ## 2. Teleportation operator -/

def TEL (π : X → Q) (R : Q → X) : X → X :=
  R ∘ π

theorem tel_def (π : X → Q) (R : Q → X) (x : X) :
    TEL π R x = R (π x) :=
  rfl

/-! ## 3. Section-only layer (no dynamics) -/

theorem teleport_preserves_quotient
    (π : X → Q) (R : Q → X) (hR : Section π R) :
    ∀ x : X, π (TEL π R x) = π x := by
  intro x
  exact hR (π x)

theorem teleport_idempotent
    (π : X → Q) (R : Q → X) (hR : Section π R) :
    Idempotent (TEL π R) := by
  intro x
  have h : π (R (π x)) = π x := hR (π x)
  calc
    TEL π R (TEL π R x) = R (π (R (π x))) := rfl
    _                   = R (π x)         := by rw [h]
    _                   = TEL π R x       := rfl

/-- TEL never leaves the constitutional class. -/
theorem tel_admissible
    (π : X → Q) (R : Q → X) (hR : Section π R) :
    MaximalConstitutional.Admissible π (TEL π R) :=
  teleport_preserves_quotient π R hR

/-- Induced quotient map of TEL is the identity on Q. -/
theorem tel_descends_id
    (π : X → Q) (R : Q → X) (hR : Section π R) :
    MaximalConstitutional.Descends π (TEL π R) (id : Q → Q) :=
  teleport_preserves_quotient π R hR

def ConstitutionalEquiv (π : X → Q) (x y : X) : Prop :=
  π x = π y

theorem teleport_equivalent
    (π : X → Q) (R : Q → X) (hR : Section π R) :
    ∀ x : X, ConstitutionalEquiv π (TEL π R x) x :=
  teleport_preserves_quotient π R hR

/-- Reconstruct once. A second reconstruction is definitionally free. -/
theorem tel_is_cheap
    (π : X → Q) (R : Q → X) (hR : Section π R) (x : X) :
    TEL π R (TEL π R x) = TEL π R x ∧ π (TEL π R x) = π x :=
  ⟨teleport_idempotent π R hR x, teleport_preserves_quotient π R hR x⟩

/-! ## 4. Dynamics: intertwining is the extra hypothesis -/

def Intertwines (π : X → Q) (T : X → X) (TQ : Q → Q) : Prop :=
  ∀ x : X, π (T x) = TQ (π x)

theorem intertwines_iff_descends
    (π : X → Q) (T : X → X) (TQ : Q → Q) :
    Intertwines π T TQ ↔ MaximalConstitutional.Descends π T TQ :=
  Iff.rfl

theorem intertwining_implies_congruence
    (π : X → Q) (T : X → X) (TQ : Q → Q)
    (h : Intertwines π T TQ) :
    MaximalConstitutional.WellDefined π T :=
  MaximalConstitutional.descends_implies_wellDefined π h

theorem one_step_preservation
    (π : X → Q) (R : Q → X) (T : X → X) (TQ : Q → Q)
    (hR : Section π R) (hT : Intertwines π T TQ) :
    ∀ x : X, π (T (TEL π R x)) = π (T x) := by
  intro x
  calc
    π (T (TEL π R x)) = TQ (π (TEL π R x)) := hT (TEL π R x)
    _                 = TQ (π x)           := by rw [teleport_preserves_quotient π R hR x]
    _                 = π (T x)            := (hT x).symm

/-! ## 5. Finite-horizon preservation -/

theorem iterate_intertwining
    (π : X → Q) (T : X → X) (TQ : Q → Q)
    (hT : Intertwines π T TQ) :
    ∀ n : Nat, ∀ x : X,
      π (iterate T n x) = iterate TQ n (π x) := by
  intro n
  induction n with
  | zero =>
      intro x
      rfl
  | succ n ih =>
      intro x
      calc
        π (iterate T (n + 1) x) = π (T (iterate T n x)) := rfl
        _ = TQ (π (iterate T n x)) := hT (iterate T n x)
        _ = TQ (iterate TQ n (π x)) := by rw [ih x]
        _ = iterate TQ (n + 1) (π x) := rfl

/-- Run TQ on Q; do not rerun T on a hidden representative. -/
theorem finite_horizon_preservation
    (π : X → Q) (R : Q → X) (T : X → X) (TQ : Q → Q)
    (hR : Section π R) (hT : Intertwines π T TQ) :
    ∀ n : Nat, ∀ x : X,
      π (iterate T n (TEL π R x)) = π (iterate T n x) := by
  intro n x
  calc
    π (iterate T n (TEL π R x))
        = iterate TQ n (π (TEL π R x)) :=
          iterate_intertwining π T TQ hT n (TEL π R x)
    _   = iterate TQ n (π x) := by
          rw [teleport_preserves_quotient π R hR x]
    _   = π (iterate T n x) :=
          (iterate_intertwining π T TQ hT n x).symm

theorem teleport_at_finite_horizon
    (π : X → Q) (R : Q → X) (T : X → X) (TQ : Q → Q)
    (hR : Section π R) (hT : Intertwines π T TQ) :
    ∀ n : Nat, ∀ x : X,
      π (iterate T n (R (π x))) = π (iterate T n x) :=
  finite_horizon_preservation π R T TQ hR hT

/-! ## 6. Observables and decisions (same factorization) -/

def Factors (π : X → Q) {Y : Type w} (O : X → Y) (OBar : Q → Y) : Prop :=
  ∀ x : X, O x = OBar (π x)

theorem factors_implies_class_invariant
    (π : X → Q) {Y : Type w} (O : X → Y) (OBar : Q → Y)
    (h : Factors π O OBar) :
    ∀ x y : X, π x = π y → O x = O y := by
  intro x y hxy
  calc
    O x = OBar (π x) := h x
    _   = OBar (π y) := by rw [hxy]
    _   = O y        := (h y).symm

theorem observable_preservation
    (π : X → Q) (R : Q → X) {Y : Type w}
    (O : X → Y) (OBar : Q → Y)
    (hO : Factors π O OBar) (hR : Section π R) :
    ∀ x : X, O (TEL π R x) = O x := by
  intro x
  calc
    O (TEL π R x) = OBar (π (TEL π R x)) := hO (TEL π R x)
    _             = OBar (π x)           := by rw [teleport_preserves_quotient π R hR x]
    _             = O x                  := (hO x).symm

theorem dynamic_observable_preservation
    (π : X → Q) (R : Q → X) (T : X → X) (TQ : Q → Q)
    {Y : Type w} (O : X → Y) (OBar : Q → Y)
    (hO : Factors π O OBar) (hR : Section π R) (hT : Intertwines π T TQ) :
    ∀ n : Nat, ∀ x : X,
      O (iterate T n (TEL π R x)) = O (iterate T n x) := by
  intro n x
  exact factors_implies_class_invariant π O OBar hO
    (iterate T n (TEL π R x)) (iterate T n x)
    (finite_horizon_preservation π R T TQ hR hT n x)

theorem decision_preservation
    (π : X → Q) (R : Q → X) {Decision : Type w}
    (D : X → Decision) (DBar : Q → Decision)
    (hD : Factors π D DBar) (hR : Section π R) :
    ∀ x : X, D (TEL π R x) = D x :=
  observable_preservation π R D DBar hD hR

theorem finite_horizon_decision_preservation
    (π : X → Q) (R : Q → X) (T : X → X) (TQ : Q → Q)
    {Decision : Type w} (D : X → Decision) (DBar : Q → Decision)
    (hD : Factors π D DBar) (hR : Section π R) (hT : Intertwines π T TQ) :
    ∀ n : Nat, ∀ x : X,
      D (iterate T n (TEL π R x)) = D (iterate T n x) :=
  dynamic_observable_preservation π R T TQ D DBar hD hR hT

/-! ## 7. Predicate form (critical / safety) -/

theorem invariant_preserved
    (π : X → Q) (R : Q → X) (C : X → Prop)
    (hFactor : ∀ x y : X, π x = π y → (C x ↔ C y))
    (hR : Section π R) :
    ∀ x : X, C (TEL π R x) ↔ C x := by
  intro x
  exact hFactor (TEL π R x) x (teleport_preserves_quotient π R hR x)

theorem critical_factors_tel
    (π : X → Q) (R : Q → X) (critical : X → Prop)
    (hC : MaximalConstitutional.CriticalFactors π critical)
    (hR : Section π R) :
    ∀ x : X, critical (TEL π R x) ↔ critical x :=
  invariant_preserved π R critical hC hR

/-! ## 8. Bounded image (no Fintype, no cardinality library) -/

/-- Operational bound: every class has a Nat code below `B`. -/
def BoundedBy (_π : X → Q) (code : Q → Nat) (B : Nat) : Prop :=
  ∀ q : Q, code q < B

theorem bounded_by_self (code : Q → Nat) (B : Nat)
    (h : ∀ q, code q < B) :
    BoundedBy (id : Q → Q) code B :=
  h

/-! ## 9. Master package — assumptions stay explicit -/

theorem constitutional_teleportation_master
    (π : X → Q) (R : Q → X) (T : X → X) (TQ : Q → Q)
    {Decision : Type w} (D : X → Decision) (DBar : Q → Decision)
    (hR : Section π R)
    (hT : Intertwines π T TQ)
    (hD : Factors π D DBar) :
    Idempotent (TEL π R) ∧
    (∀ x : X, π (TEL π R x) = π x) ∧
    MaximalConstitutional.Admissible π (TEL π R) ∧
    (∀ n : Nat, ∀ x : X,
      π (iterate T n (TEL π R x)) = π (iterate T n x)) ∧
    (∀ n : Nat, ∀ x : X,
      π (iterate T n x) = iterate TQ n (π x)) ∧
    (∀ x : X, D (TEL π R x) = D x) ∧
    (∀ n : Nat, ∀ x : X,
      D (iterate T n (TEL π R x)) = D (iterate T n x)) := by
  refine ⟨?idemp, ?cls, ?adm, ?fin, ?quot, ?dec, ?dyn⟩
  · exact teleport_idempotent π R hR
  · exact teleport_preserves_quotient π R hR
  · exact tel_admissible π R hR
  · exact finite_horizon_preservation π R T TQ hR hT
  · exact iterate_intertwining π T TQ hT
  · exact decision_preservation π R D DBar hD hR
  · exact finite_horizon_decision_preservation π R T TQ D DBar hD hR hT

end Chronofold.ConstitutionalTeleportation

/-! ## AGD instantiation: π = pi, R = agdSection -/

namespace Chronofold.AGD

open Chronofold.ConstitutionalTeleportation
open Chronofold.MaximalConstitutional

universe u_agd w_agd

noncomputable def agdTEL (α : Type u_agd) (Ω : Omega α) (C : Covariant α) :
    Operator α :=
  TEL (pi α Ω C) (agdSection α Ω C)

theorem agd_section_is_section
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α) :
    Section (pi α Ω C) (agdSection α Ω C) :=
  agd_reconstruction_correct α Ω C

theorem agd_tel_preserves_class
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α) (s : State α) :
    pi α Ω C (agdTEL α Ω C s) = pi α Ω C s :=
  teleport_preserves_quotient (pi α Ω C) (agdSection α Ω C)
    (agd_section_is_section α Ω C) s

theorem agd_tel_idempotent
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α) :
    Idempotent (agdTEL α Ω C) :=
  teleport_idempotent (pi α Ω C) (agdSection α Ω C)
    (agd_section_is_section α Ω C)

theorem agd_tel_admissible
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α) :
    Admissible α Ω C (agdTEL α Ω C) := by
  intro s
  exact Quotient.exact (agd_tel_preserves_class α Ω C s)

theorem agd_tel_TBar_is_id
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α)
    (hT : Admissible α Ω C (agdTEL α Ω C)) (s : State α) :
    TBar α Ω C (agdTEL α Ω C) hT (pi α Ω C s) = pi α Ω C s := by
  have h := TBar_sound α Ω C (agdTEL α Ω C) hT s
  exact h.trans (agd_tel_preserves_class α Ω C s)

theorem agd_admissible_intertwines
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T) :
    Intertwines (pi α Ω C) T (TBar α Ω C T hT) :=
  agd_TBar_descends α Ω C T hT

theorem agd_omega_factors
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α) :
    Factors (pi α Ω C) Ω
      (fun q => Ω (agdSection α Ω C q)) := by
  intro s
  have h : pi α Ω C (agdSection α Ω C (pi α Ω C s)) = pi α Ω C s :=
    agd_tel_preserves_class α Ω C s
  exact (Quotient.exact h).1.symm

theorem agd_C_factors
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α) :
    Factors (pi α Ω C) C
      (fun q => C (agdSection α Ω C q)) := by
  intro s
  have h : pi α Ω C (agdSection α Ω C (pi α Ω C s)) = pi α Ω C s :=
    agd_tel_preserves_class α Ω C s
  exact (Quotient.exact h).2.symm

theorem agd_tel_preserves_omega
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α) (s : State α) :
    Ω (agdTEL α Ω C s) = Ω s :=
  observable_preservation (pi α Ω C) (agdSection α Ω C) Ω
    (fun q => Ω (agdSection α Ω C q))
    (agd_omega_factors α Ω C) (agd_section_is_section α Ω C) s

theorem agd_tel_preserves_C
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α) (s : State α) :
    C (agdTEL α Ω C s) = C s :=
  observable_preservation (pi α Ω C) (agdSection α Ω C) C
    (fun q => C (agdSection α Ω C q))
    (agd_C_factors α Ω C) (agd_section_is_section α Ω C) s

theorem agd_constitutional_teleportation
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T) :
    Idempotent (agdTEL α Ω C) ∧
    (∀ s, pi α Ω C (agdTEL α Ω C s) = pi α Ω C s) ∧
    Admissible α Ω C (agdTEL α Ω C) ∧
    Intertwines (pi α Ω C) T (TBar α Ω C T hT) ∧
    (∀ n s,
      pi α Ω C (ConstitutionalTeleportation.iterate T n (agdTEL α Ω C s)) =
        pi α Ω C (ConstitutionalTeleportation.iterate T n s)) ∧
    (∀ s, Ω (agdTEL α Ω C s) = Ω s) ∧
    (∀ s, C (agdTEL α Ω C s) = C s) := by
  refine ⟨?idemp, ?cls, ?adm, ?int, ?fin, ?o, ?c⟩
  · exact agd_tel_idempotent α Ω C
  · exact agd_tel_preserves_class α Ω C
  · exact agd_tel_admissible α Ω C
  · exact agd_admissible_intertwines α Ω C T hT
  · exact finite_horizon_preservation (pi α Ω C) (agdSection α Ω C)
      T (TBar α Ω C T hT)
      (agd_section_is_section α Ω C)
      (agd_admissible_intertwines α Ω C T hT)
  · exact agd_tel_preserves_omega α Ω C
  · exact agd_tel_preserves_C α Ω C

end Chronofold.AGD

/-! ## EMV instantiation -/

namespace Chronofold.EMV

open Chronofold.AGD
open Chronofold.ConstitutionalTeleportation
open Chronofold.MaximalConstitutional

noncomputable def emvR : QStar EmvPayload Ω C → EmvState :=
  agdSection EmvPayload Ω C

noncomputable def emvTEL : Operator EmvPayload :=
  agdTEL EmvPayload Ω C

theorem emv_section : Section emvPi emvR :=
  agd_section_is_section EmvPayload Ω C

theorem emv_tel_idempotent : Idempotent emvTEL :=
  agd_tel_idempotent EmvPayload Ω C

theorem emv_tel_preserves_class (s : EmvState) :
    emvPi (emvTEL s) = emvPi s :=
  agd_tel_preserves_class EmvPayload Ω C s

theorem emv_tel_admissible : Admissible EmvPayload Ω C emvTEL :=
  agd_tel_admissible EmvPayload Ω C

theorem emv_overlay_intertwines (note : Nat) :
    Intertwines emvPi (annotate note)
      (TBar EmvPayload Ω C (annotate note) (annotate_admissible note)) :=
  agd_TBar_descends EmvPayload Ω C (annotate note) (annotate_admissible note)

theorem emv_tel_preserves_failed (s : EmvState) :
    criticalFailed (emvTEL s) ↔ criticalFailed s :=
  critical_factors_tel emvPi emvR criticalFailed
    criticalFailed_factors_pi emv_section s

theorem emv_tel_preserves_approved (s : EmvState) :
    criticalApproved (emvTEL s) ↔ criticalApproved s :=
  critical_factors_tel emvPi emvR criticalApproved
    criticalApproved_factors_pi emv_section s

theorem emv_phase_code_lt (p : Phase) : phaseCode p < 10 := by
  cases p <;> simp [phaseCode]

theorem emv_outcome_code_lt (o : Outcome) : outcomeCode o < 4 := by
  cases o <;> simp [outcomeCode]

/-- Constitutional pair lives in a 10 × 4 rectangle. -/
def emvClassCode (s : EmvState) : Nat :=
  Ω s * 4 + C s

theorem emv_class_code_lt (s : EmvState) : emvClassCode s < 40 := by
  have hp : Ω s < 10 := emv_phase_code_lt s.payload.phase
  have ho : C s < 4 := emv_outcome_code_lt s.payload.outcome
  have hsum : Ω s * 4 + C s < Ω s * 4 + 4 := Nat.add_lt_add_left ho (Ω s * 4)
  have hle : Ω s * 4 + 4 ≤ 40 := by
    have : Ω s + 1 ≤ 10 := Nat.succ_le_of_lt hp
    have : (Ω s + 1) * 4 ≤ 10 * 4 := Nat.mul_le_mul_right 4 this
    have heq : Ω s * 4 + 4 = (Ω s + 1) * 4 := by
      rw [Nat.succ_mul]
    exact heq.symm ▸ this
  exact Nat.lt_of_lt_of_le hsum hle

theorem emv_overlay_finite_horizon (note n : Nat) (s : EmvState) :
    emvPi (ConstitutionalTeleportation.iterate (annotate note) n (emvTEL s)) =
      emvPi (ConstitutionalTeleportation.iterate (annotate note) n s) :=
  finite_horizon_preservation emvPi emvR (annotate note)
    (TBar EmvPayload Ω C (annotate note) (annotate_admissible note))
    emv_section (emv_overlay_intertwines note) n s

/-- TEL + admissible overlay: class, failure bit, and iteration stay put.
    `transition` is excluded: it is not well-defined on `emvPi`. -/
theorem emv_constitutional_teleportation (note : Nat) :
    Idempotent emvTEL ∧
    Admissible EmvPayload Ω C emvTEL ∧
    Admissible EmvPayload Ω C (annotate note) ∧
    ¬ MaximalConstitutional.WellDefined emvPi (transition stepEvent) ∧
    (∀ s, emvPi (emvTEL s) = emvPi s) ∧
    (∀ s, criticalFailed (emvTEL s) ↔ criticalFailed s) ∧
    (∀ s, emvClassCode s < 40) := by
  refine ⟨emv_tel_idempotent, emv_tel_admissible,
          annotate_admissible note, transition_not_wellDefined,
          emv_tel_preserves_class, emv_tel_preserves_failed,
          emv_class_code_lt⟩

end Chronofold.EMV
