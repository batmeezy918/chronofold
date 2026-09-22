import Chronofold.ConstitutionalTeleportation

/-!
# Quotient Validation

Kernel-checked validation chain:

  equivalence
    → section / reconstruction
    → operator descent
    → decision factorization
    → finite-horizon preservation
    → collision exclusion

Lean 4 core only. No unfinished goals. No performance claim.

Skeleton repairs
* `decision_tel_preserved` required a section but supplied `rfl`.
  That is fibre collapse (`R ∘ π = id`), not a section (`π ∘ R = id`).
  The repaired theorem takes `Section π R` as an explicit hypothesis.
* `Function.iterate` is replaced by the core recursor already used
  by ConstitutionalTeleportation.
* Measurement lives in a record. It is not a theorem.

Operational reading
  Reconstruct once (`TEL`).
  Execute only operators that intertwine.
  Reject any decision that collides on a fibre.
-/

namespace Chronofold.QuotientValidation

open Chronofold.ConstitutionalTeleportation

universe u v w

variable {X : Type u} {Q : Type v}

def QuotientEq (π : X → Q) (x y : X) : Prop :=
  π x = π y

theorem quotientEq_refl (π : X → Q) (x : X) :
    QuotientEq π x x :=
  rfl

theorem quotientEq_symm (π : X → Q) {x y : X} :
    QuotientEq π x y → QuotientEq π y x :=
  Eq.symm

theorem quotientEq_trans (π : X → Q) {x y z : X} :
    QuotientEq π x y → QuotientEq π y z → QuotientEq π x z :=
  Eq.trans

theorem quotientEq_equivalence (π : X → Q) :
    Equivalence (QuotientEq π) :=
  ⟨quotientEq_refl π,
   fun {_ _} h => quotientEq_symm π h,
   fun {_ _ _} hxy hyz => quotientEq_trans π hxy hyz⟩

def IsSection (π : X → Q) (R : Q → X) : Prop :=
  Section π R

theorem isSection_comp_id (π : X → Q) (R : Q → X) :
    IsSection π R ↔ π ∘ R = id :=
  section_iff_comp_id π R

theorem tel_projection
    (π : X → Q) (R : Q → X) (hR : IsSection π R) (x : X) :
    π (TEL π R x) = π x :=
  teleport_preserves_quotient π R hR x

theorem tel_admissible
    (π : X → Q) (R : Q → X) (hR : IsSection π R) (x : X) :
    QuotientEq π (TEL π R x) x :=
  tel_projection π R hR x

theorem tel_idempotent
    (π : X → Q) (R : Q → X) (hR : IsSection π R) (x : X) :
    TEL π R (TEL π R x) = TEL π R x :=
  teleport_idempotent π R hR x

theorem quotient_tel_identity
    (π : X → Q) (R : Q → X) (hR : IsSection π R) (q : Q) :
    π (TEL π R (R q)) = q := by
  calc
    π (TEL π R (R q)) = π (R q) := tel_projection π R hR (R q)
    _                 = q       := hR q

def Intertwines (π : X → Q) (T : X → X) (TBar : Q → Q) : Prop :=
  ConstitutionalTeleportation.Intertwines π T TBar

theorem quotient_step
    (π : X → Q) (T : X → X) (TBar : Q → Q)
    (h : Intertwines π T TBar) (x : X) :
    π (T x) = TBar (π x) :=
  h x

theorem quotient_iterate
    (π : X → Q) (T : X → X) (TBar : Q → Q)
    (h : Intertwines π T TBar) (x : X) :
    ∀ n : Nat,
      π (ConstitutionalTeleportation.iterate T n x) =
        ConstitutionalTeleportation.iterate TBar n (π x) :=
  fun n => iterate_intertwining π T TBar h n x

theorem tel_trajectory_preserved
    (π : X → Q) (R : Q → X) (T : X → X) (TBar : Q → Q)
    (hR : IsSection π R) (hT : Intertwines π T TBar) (x : X) :
    ∀ n : Nat,
      π (ConstitutionalTeleportation.iterate T n (TEL π R x)) =
        π (ConstitutionalTeleportation.iterate T n x) :=
  fun n => finite_horizon_preservation π R T TBar hR hT n x

def DecisionFactorizes (π : X → Q) {Y : Type w}
    (D : X → Y) (DBar : Q → Y) : Prop :=
  Factors π D DBar

theorem decision_preserved
    (π : X → Q) {Y : Type w} (D : X → Y) (DBar : Q → Y)
    (hF : DecisionFactorizes π D DBar)
    {x y : X} (hEq : QuotientEq π x y) :
    D x = D y :=
  factors_implies_class_invariant π D DBar hF x y hEq

/-- Repaired: section is an explicit hypothesis, not `rfl`. -/
theorem decision_tel_preserved
    (π : X → Q) (R : Q → X) {Y : Type w}
    (D : X → Y) (DBar : Q → Y)
    (hF : DecisionFactorizes π D DBar)
    (hR : IsSection π R) (x : X) :
    D (TEL π R x) = D x :=
  observable_preservation π R D DBar hF hR x

theorem constitutional_teleportation
    (π : X → Q) (R : Q → X) (T : X → X) (TBar : Q → Q)
    {Y : Type w} (D : X → Y) (DBar : Q → Y)
    (hR : IsSection π R)
    (hT : Intertwines π T TBar)
    (hF : DecisionFactorizes π D DBar)
    (x : X) :
    D (TEL π R x) = D x ∧
    ∀ n : Nat,
      π (ConstitutionalTeleportation.iterate T n (TEL π R x)) =
        π (ConstitutionalTeleportation.iterate T n x) :=
  ⟨decision_tel_preserved π R D DBar hF hR x,
   tel_trajectory_preserved π R T TBar hR hT x⟩

def NontrivialFibre (π : X → Q) : Prop :=
  ∃ x y : X, x ≠ y ∧ π x = π y

theorem nontrivial_fibre_witness (π : X → Q) (h : NontrivialFibre π) :
    ∃ x y : X, x ≠ y ∧ QuotientEq π x y :=
  h

theorem retract_forbids_nontrivial
    (π : X → Q) (R : Q → X) (hRet : Retract π R) :
    ¬ NontrivialFibre π := by
  intro ⟨x, y, hne, heq⟩
  exact hne (retract_implies_injective_pi π R hRet heq)

def DecisionCollision (π : X → Q) {Y : Type w} (D : X → Y) : Prop :=
  ∃ x y : X, π x = π y ∧ D x ≠ D y

theorem factorization_no_collision
    (π : X → Q) {Y : Type w} (D : X → Y) (DBar : Q → Y)
    (hF : DecisionFactorizes π D DBar) :
    ¬ DecisionCollision π D := by
  intro ⟨x, y, hπ, hD⟩
  exact hD (decision_preserved π D DBar hF hπ)

noncomputable def inducedDecision
    (π : X → Q) {Y : Type w} (D : X → Y)
    (hπ : Function.Surjective π)
    (_hNo : ¬ DecisionCollision π D) :
    Q → Y :=
  fun q => D (Classical.choose (hπ q))

theorem inducedDecision_factors
    (π : X → Q) {Y : Type w} (D : X → Y)
    (hπ : Function.Surjective π)
    (hNo : ¬ DecisionCollision π D) :
    DecisionFactorizes π D (inducedDecision π D hπ hNo) := by
  intro x
  have hx : π (Classical.choose (hπ (π x))) = π x :=
    Classical.choose_spec (hπ (π x))
  have hEq : D (Classical.choose (hπ (π x))) = D x := by
    cases Classical.em (D (Classical.choose (hπ (π x))) = D x) with
    | inl heq => exact heq
    | inr hne =>
        exact False.elim (hNo ⟨Classical.choose (hπ (π x)), x, hx, hne⟩)
  exact hEq.symm

theorem factorization_iff_no_collision
    (π : X → Q) {Y : Type w} (D : X → Y)
    (hπ : Function.Surjective π) :
    (¬ DecisionCollision π D) ↔
      ∃ DBar : Q → Y, DecisionFactorizes π D DBar := by
  constructor
  · intro hNo
    exact ⟨inducedDecision π D hπ hNo,
           inducedDecision_factors π D hπ hNo⟩
  · intro ⟨DBar, hF⟩
    exact factorization_no_collision π D DBar hF

theorem reconstruction_decision
    (π : X → Q) (R : Q → X) {Y : Type w}
    (D : X → Y) (DBar : Q → Y)
    (hR : IsSection π R)
    (hF : DecisionFactorizes π D DBar)
    (q : Q) :
    D (R q) = DBar q := by
  calc
    D (R q) = DBar (π (R q)) := hF (R q)
    _       = DBar q         := by rw [hR q]

theorem decision_teleportation
    (π : X → Q) (R : Q → X) {Y : Type w}
    (D : X → Y) (DBar : Q → Y)
    (hR : IsSection π R)
    (hF : DecisionFactorizes π D DBar)
    (x : X) :
    D (R (π x)) = D x :=
  decision_tel_preserved π R D DBar hF hR x

structure MeasurementResult where
  baselineCost        : Nat
  projectionCost      : Nat
  quotientCost        : Nat
  reconstructionCost  : Nat
  verificationCost    : Nat

def totalReducedCost (m : MeasurementResult) : Nat :=
  m.projectionCost + m.quotientCost +
  m.reconstructionCost + m.verificationCost

def HasMeasuredAdvantage (m : MeasurementResult) : Prop :=
  totalReducedCost m < m.baselineCost

structure ValidationCertificate
    (π : X → Q) (T : X → X) (TBar : Q → Q) (R : Q → X)
    {Y : Type w} (D : X → Y) (DBar : Q → Y) where
  sectionValid        : IsSection π R
  operatorIntertwines : Intertwines π T TBar
  decisionFactorizes  : DecisionFactorizes π D DBar

theorem validated_system
    (π : X → Q) (T : X → X) (TBar : Q → Q) (R : Q → X)
    {Y : Type w} (D : X → Y) (DBar : Q → Y)
    (cert : ValidationCertificate π T TBar R D DBar)
    (x : X) :
    D (TEL π R x) = D x ∧
    ∀ n : Nat,
      π (ConstitutionalTeleportation.iterate T n (TEL π R x)) =
        π (ConstitutionalTeleportation.iterate T n x) :=
  constitutional_teleportation π R T TBar D DBar
    cert.sectionValid cert.operatorIntertwines cert.decisionFactorizes x

theorem validated_no_collision
    (π : X → Q) (T : X → X) (TBar : Q → Q) (R : Q → X)
    {Y : Type w} (D : X → Y) (DBar : Q → Y)
    (cert : ValidationCertificate π T TBar R D DBar) :
    ¬ DecisionCollision π D :=
  factorization_no_collision π D DBar cert.decisionFactorizes

theorem validated_master
    (π : X → Q) (T : X → X) (TBar : Q → Q) (R : Q → X)
    {Y : Type w} (D : X → Y) (DBar : Q → Y)
    (cert : ValidationCertificate π T TBar R D DBar) :
    Idempotent (TEL π R) ∧
    (∀ x, π (TEL π R x) = π x) ∧
    (∀ n x,
      π (ConstitutionalTeleportation.iterate T n (TEL π R x)) =
        π (ConstitutionalTeleportation.iterate T n x)) ∧
    (∀ n x,
      π (ConstitutionalTeleportation.iterate T n x) =
        ConstitutionalTeleportation.iterate TBar n (π x)) ∧
    (∀ x, D (TEL π R x) = D x) ∧
    (∀ n x,
      D (ConstitutionalTeleportation.iterate T n (TEL π R x)) =
        D (ConstitutionalTeleportation.iterate T n x)) ∧
    ¬ DecisionCollision π D := by
  refine ⟨?idemp, ?cls, ?fin, ?quot, ?dec, ?dyn, ?nc⟩
  · exact teleport_idempotent π R cert.sectionValid
  · exact teleport_preserves_quotient π R cert.sectionValid
  · exact finite_horizon_preservation π R T TBar
      cert.sectionValid cert.operatorIntertwines
  · exact iterate_intertwining π T TBar cert.operatorIntertwines
  · exact decision_preservation π R D DBar
      cert.decisionFactorizes cert.sectionValid
  · exact finite_horizon_decision_preservation π R T TBar D DBar
      cert.decisionFactorizes cert.sectionValid cert.operatorIntertwines
  · exact validated_no_collision π T TBar R D DBar cert

end Chronofold.QuotientValidation

namespace Chronofold.AGD

open Chronofold.ConstitutionalTeleportation
open Chronofold.QuotientValidation
open Chronofold.MaximalConstitutional

universe u_agd

theorem agd_no_omega_collision
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α) :
    ¬ DecisionCollision (pi α Ω C) Ω :=
  factorization_no_collision (pi α Ω C) Ω
    (fun q => Ω (agdSection α Ω C q))
    (agd_omega_factors α Ω C)

theorem agd_no_C_collision
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α) :
    ¬ DecisionCollision (pi α Ω C) C :=
  factorization_no_collision (pi α Ω C) C
    (fun q => C (agdSection α Ω C q))
    (agd_C_factors α Ω C)

noncomputable def agdOmegaCert
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T) :
    ValidationCertificate
      (pi α Ω C) T (TBar α Ω C T hT)
      (agdSection α Ω C) Ω
      (fun q => Ω (agdSection α Ω C q)) where
  sectionValid        := agd_section_is_section α Ω C
  operatorIntertwines := agd_admissible_intertwines α Ω C T hT
  decisionFactorizes  := agd_omega_factors α Ω C

theorem agd_validated_omega
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T) (s : State α) :
    Ω (agdTEL α Ω C s) = Ω s ∧
    ∀ n : Nat,
      pi α Ω C (ConstitutionalTeleportation.iterate T n (agdTEL α Ω C s)) =
        pi α Ω C (ConstitutionalTeleportation.iterate T n s) :=
  validated_system
    (pi α Ω C) T (TBar α Ω C T hT) (agdSection α Ω C)
    Ω (fun q => Ω (agdSection α Ω C q))
    (agdOmegaCert α Ω C T hT) s

theorem agd_quotient_validation
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (_hT : Admissible α Ω C T) :
    Idempotent (agdTEL α Ω C) ∧
    (∀ s, pi α Ω C (agdTEL α Ω C s) = pi α Ω C s) ∧
    Admissible α Ω C (agdTEL α Ω C) ∧
    ¬ DecisionCollision (pi α Ω C) Ω ∧
    ¬ DecisionCollision (pi α Ω C) C ∧
    (∀ s, Ω (agdTEL α Ω C s) = Ω s) ∧
    (∀ s, C (agdTEL α Ω C s) = C s) := by
  refine ⟨?idemp, ?cls, ?adm, ?nΩ, ?nC, ?o, ?c⟩
  · exact agd_tel_idempotent α Ω C
  · exact agd_tel_preserves_class α Ω C
  · exact agd_tel_admissible α Ω C
  · exact agd_no_omega_collision α Ω C
  · exact agd_no_C_collision α Ω C
  · exact agd_tel_preserves_omega α Ω C
  · exact agd_tel_preserves_C α Ω C

end Chronofold.AGD

namespace Chronofold.EMV

open Chronofold.AGD
open Chronofold.ConstitutionalTeleportation
open Chronofold.QuotientValidation
open Chronofold.MaximalConstitutional

def phaseDecision (s : EmvState) : Phase :=
  s.payload.phase

noncomputable def phaseDecisionBar (q : QStar EmvPayload Ω C) : Phase :=
  (emvR q).payload.phase

theorem phaseDecision_factors :
    DecisionFactorizes emvPi phaseDecision phaseDecisionBar := by
  intro s
  have h : emvPi (emvR (emvPi s)) = emvPi s :=
    emv_tel_preserves_class s
  exact phaseCode_inj (Quotient.exact h).1.symm

theorem emv_no_phase_collision :
    ¬ DecisionCollision emvPi phaseDecision :=
  factorization_no_collision emvPi phaseDecision phaseDecisionBar
    phaseDecision_factors

theorem emv_nontrivial_fibre : NontrivialFibre emvPi := by
  refine ⟨initial, lateInit, ?hne, initial_late_same_class⟩
  intro h
  have : (0 : Nat) = 5 := congrArg (fun s : EmvState => s.payload.sequence) h
  cases this

noncomputable def emvPhaseCert (note : Nat) :
    ValidationCertificate
      emvPi (annotate note)
      (TBar EmvPayload Ω C (annotate note) (annotate_admissible note))
      emvR phaseDecision phaseDecisionBar where
  sectionValid        := emv_section
  operatorIntertwines := emv_overlay_intertwines note
  decisionFactorizes  := phaseDecision_factors

theorem emv_validated_phase (note : Nat) (s : EmvState) :
    phaseDecision (emvTEL s) = phaseDecision s ∧
    ∀ n : Nat,
      emvPi (ConstitutionalTeleportation.iterate (annotate note) n (emvTEL s)) =
        emvPi (ConstitutionalTeleportation.iterate (annotate note) n s) :=
  validated_system emvPi (annotate note)
    (TBar EmvPayload Ω C (annotate note) (annotate_admissible note))
    emvR phaseDecision phaseDecisionBar
    (emvPhaseCert note) s

theorem emv_quotient_validation (note : Nat) :
    NontrivialFibre emvPi ∧
    ¬ DecisionCollision emvPi phaseDecision ∧
    IsSection emvPi emvR ∧
    QuotientValidation.Intertwines emvPi (annotate note)
      (TBar EmvPayload Ω C (annotate note) (annotate_admissible note)) ∧
    ¬ WellDefined emvPi (transition stepEvent) ∧
    Idempotent emvTEL ∧
    (∀ s, phaseDecision (emvTEL s) = phaseDecision s) ∧
    (∀ s, criticalFailed (emvTEL s) ↔ criticalFailed s) := by
  refine ⟨emv_nontrivial_fibre,
          emv_no_phase_collision,
          emv_section,
          emv_overlay_intertwines note,
          transition_not_wellDefined,
          emv_tel_idempotent,
          ?phase,
          emv_tel_preserves_failed⟩
  intro s
  exact (emv_validated_phase note s).1

end Chronofold.EMV
