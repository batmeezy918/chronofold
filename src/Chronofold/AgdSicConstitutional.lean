/-!
# AGD × SIC — Elevated Constitutional Closure
Version: 1.0 (Lean 4.29, Chronofold package, no Mathlib)

All theorems proved with no sorry.
Observables encoded as predicate (State → Obs) → Prop (no Mathlib Set).
Projection/reconstruction binders use ASCII pi/re (Lean Π is a binder keyword).
-/

namespace Chronofold.AGDSIC

universe u v w

def OperationalEq {State : Type u} {Obs : Type w}
    (Observables : (State → Obs) → Prop) (x y : State) : Prop :=
  ∀ (f : State → Obs), Observables f → f x = f y

theorem operationalEq_refl {State : Type u} {Obs : Type w}
    (Observables : (State → Obs) → Prop) (x : State) :
    OperationalEq Observables x x := by
  intro f hf
  rfl

theorem operationalEq_symm {State : Type u} {Obs : Type w}
    (Observables : (State → Obs) → Prop) {x y : State}
    (hxy : OperationalEq Observables x y) :
    OperationalEq Observables y x := by
  intro f hf
  exact (hxy f hf).symm

theorem operationalEq_trans {State : Type u} {Obs : Type w}
    (Observables : (State → Obs) → Prop) {x y z : State}
    (hxy : OperationalEq Observables x y)
    (hyz : OperationalEq Observables y z) :
    OperationalEq Observables x z := by
  intro f hf
  exact (hxy f hf).trans (hyz f hf)

theorem operationalEq_equivalence {State : Type u} {Obs : Type w}
    (Observables : (State → Obs) → Prop) :
    Equivalence (OperationalEq Observables) :=
  ⟨operationalEq_refl Observables,
   fun {_ _} h => operationalEq_symm Observables h,
   fun {_ _ _} hxy hyz => operationalEq_trans Observables hxy hyz⟩

def ObservableFactorsThroughInvariant {State : Type u} {Quot : Type v} {Obs : Type w}
    (Ω : State → Quot) (Observables : (State → Obs) → Prop) : Prop :=
  ∀ (f : State → Obs), Observables f →
    ∃ g : Quot → Obs, ∀ x : State, f x = g (Ω x)

def InvariantPreserving {State : Type u} {Quot : Type v}
    (Ω : State → Quot) (O : State → State) : Prop :=
  ∀ x : State, Ω (O x) = Ω x

theorem invariant_identity {State : Type u} {Quot : Type v}
    (Ω : State → Quot) :
    InvariantPreserving Ω (fun x => x) := by
  intro x
  rfl

theorem invariant_comp {State : Type u} {Quot : Type v}
    (Ω : State → Quot) {O₁ O₂ : State → State}
    (h₁ : InvariantPreserving Ω O₁)
    (h₂ : InvariantPreserving Ω O₂) :
    InvariantPreserving Ω (fun x => O₂ (O₁ x)) := by
  intro x
  have h₁x : Ω (O₁ x) = Ω x := h₁ x
  have h₂x : Ω (O₂ (O₁ x)) = Ω (O₁ x) := h₂ (O₁ x)
  exact h₂x.trans h₁x

def SICOperatorAlgebra {State : Type u} {Quot : Type v}
    (Ω : State → Quot) (O : State → State) : Prop :=
  InvariantPreserving Ω O

theorem SICOperatorAlgebra_id {State : Type u} {Quot : Type v}
    (Ω : State → Quot) :
    SICOperatorAlgebra Ω (fun x : State => x) :=
  invariant_identity Ω

theorem SICOperatorAlgebra_comp {State : Type u} {Quot : Type v}
    (Ω : State → Quot) {O₁ O₂ : State → State}
    (h₁ : SICOperatorAlgebra Ω O₁)
    (h₂ : SICOperatorAlgebra Ω O₂) :
    SICOperatorAlgebra Ω (fun x => O₂ (O₁ x)) :=
  invariant_comp Ω h₁ h₂

theorem invariant_preservation_implies_operational_equivalence
    {State : Type u} {Quot : Type v} {Obs : Type w}
    (Ω : State → Quot) (Observables : (State → Obs) → Prop)
    (hfactor : ObservableFactorsThroughInvariant Ω Observables)
    {O : State → State}
    (hΩ : InvariantPreserving Ω O) :
    ∀ x : State, OperationalEq Observables (O x) x := by
  intro x f hf
  obtain ⟨g, hg⟩ := hfactor f hf
  rw [hg (O x), hg x, hΩ x]

def Governor {State : Type u} {Quot : Type v}
    (Ω : State → Quot) (O : State → State) : Prop :=
  InvariantPreserving Ω O

theorem governor_iff_invariant {State : Type u} {Quot : Type v}
    (Ω : State → Quot) {O : State → State} :
    Governor Ω O ↔ InvariantPreserving Ω O :=
  Iff.rfl

theorem governor_sound {State : Type u} {Quot : Type v}
    (Ω : State → Quot) {O : State → State}
    (hO : Governor Ω O) :
    ∀ x : State, Ω (O x) = Ω x :=
  hO

theorem governor_identity {State : Type u} {Quot : Type v}
    (Ω : State → Quot) :
    Governor Ω (fun x => x) :=
  invariant_identity Ω

theorem governor_composition_closed {State : Type u} {Quot : Type v}
    (Ω : State → Quot) {O₁ O₂ : State → State}
    (h₁ : Governor Ω O₁) (h₂ : Governor Ω O₂) :
    Governor Ω (fun x => O₂ (O₁ x)) :=
  invariant_comp Ω h₁ h₂

theorem governor_generates_closed_operator_system
    {State : Type u} {Quot : Type v}
    (Ω : State → Quot) {O₁ O₂ : State → State}
    (h₁ : Governor Ω O₁) (h₂ : Governor Ω O₂) :
    Governor Ω (fun x => O₂ (O₁ x)) ∧ Governor Ω (fun x => x) :=
  ⟨governor_composition_closed Ω h₁ h₂, governor_identity Ω⟩

theorem governor_preserves_declared_information
    {State : Type u} {Quot : Type v} {Obs : Type w}
    (Ω : State → Quot) (Observables : (State → Obs) → Prop)
    (hfactor : ObservableFactorsThroughInvariant Ω Observables)
    {O : State → State}
    (hO : Governor Ω O) :
    ∀ x : State, OperationalEq Observables (O x) x :=
  invariant_preservation_implies_operational_equivalence Ω Observables hfactor hO

theorem quotient_descent
    {State : Type u} {Quot : Type v} {Obs : Type w}
    (Ω : State → Quot) (Observables : (State → Obs) → Prop)
    (hfactor : ObservableFactorsThroughInvariant Ω Observables)
    {O : State → State}
    (hO : Governor Ω O)
    {x y : State}
    (hxy : OperationalEq Observables x y) :
    OperationalEq Observables (O x) (O y) := by
  intro f hf
  have hx : f (O x) = f x :=
    governor_preserves_declared_information Ω Observables hfactor hO x f hf
  have hy : f (O y) = f y :=
    governor_preserves_declared_information Ω Observables hfactor hO y f hf
  exact hx.trans ((hxy f hf).trans hy.symm)

def ReconstructionCorrect {State : Type u} {Obs : Type w}
    (Observables : (State → Obs) → Prop)
    (pi re : State → State) : Prop :=
  ∀ x : State, OperationalEq Observables (re (pi x)) x

theorem reconstruction_modulo_observables
    {State : Type u} {Obs : Type w}
    (Observables : (State → Obs) → Prop)
    (pi re : State → State)
    (hR : ReconstructionCorrect Observables pi re) :
    ∀ x : State, OperationalEq Observables (re (pi x)) x :=
  hR

theorem reconstruction_preserves_declared_information
    {State : Type u} {Obs : Type w}
    (Observables : (State → Obs) → Prop)
    (pi re : State → State)
    (hR : ReconstructionCorrect Observables pi re)
    {f : State → Obs}
    (hf : Observables f) :
    ∀ x : State, f (re (pi x)) = f x := by
  intro x
  exact hR x f hf

def ReplayCorrect {State : Type u} {Obs : Type w}
    (Observables : (State → Obs) → Prop)
    (Replay : State → State) : Prop :=
  ∀ x : State, OperationalEq Observables (Replay x) x

theorem replay_preserves_declared_information
    {State : Type u} {Obs : Type w}
    (Observables : (State → Obs) → Prop)
    {Replay : State → State}
    (hReplay : ReplayCorrect Observables Replay) :
    ∀ x : State, OperationalEq Observables (Replay x) x :=
  hReplay

theorem constitutional_roundtrip
    {State : Type u} {Quot : Type v} {Obs : Type w}
    (Ω : State → Quot)
    (Observables : (State → Obs) → Prop)
    (pi re : State → State)
    (hR : ReconstructionCorrect Observables pi re)
    {O : State → State}
    (_hO : Governor Ω O) :
    ∀ x : State, OperationalEq Observables (re (pi (O x))) (O x) := by
  intro x
  exact hR (O x)

def LawfulTrajectory {State : Type u}
    (O : State → State) : Nat → State → State
  | 0,     x => x
  | n + 1, x => O (LawfulTrajectory O n x)

theorem lawfulTrajectory_preserves_invariant
    {State : Type u} {Quot : Type v}
    (Ω : State → Quot)
    {O : State → State}
    (hO : Governor Ω O) :
    ∀ (n : Nat) (x : State),
      Ω (LawfulTrajectory O n x) = Ω x := by
  intro n
  induction n with
  | zero =>
      intro x
      rfl
  | succ n ih =>
      intro x
      have hstep : Ω (O (LawfulTrajectory O n x)) = Ω (LawfulTrajectory O n x) :=
        hO (LawfulTrajectory O n x)
      have hprev : Ω (LawfulTrajectory O n x) = Ω x := ih x
      exact hstep.trans hprev

theorem lawfulTrajectory_preserves_declared_information
    {State : Type u} {Quot : Type v} {Obs : Type w}
    (Ω : State → Quot)
    (Observables : (State → Obs) → Prop)
    (hfactor : ObservableFactorsThroughInvariant Ω Observables)
    {O : State → State}
    (hO : Governor Ω O) :
    ∀ (n : Nat) (x : State),
      OperationalEq Observables (LawfulTrajectory O n x) x := by
  intro n x
  have htraj : InvariantPreserving Ω (LawfulTrajectory O n) := by
    intro y
    exact lawfulTrajectory_preserves_invariant Ω hO n y
  exact invariant_preservation_implies_operational_equivalence
    Ω Observables hfactor htraj x

theorem sic_agd_constitutional_closure
    {State : Type u} {Quot : Type v} {Obs : Type w}
    (Ω : State → Quot)
    (Observables : (State → Obs) → Prop)
    (pi re : State → State)
    (hfactor : ObservableFactorsThroughInvariant Ω Observables)
    (hR : ReconstructionCorrect Observables pi re)
    {O : State → State}
    (hO : Governor Ω O) :
    (∀ x : State, Ω (O x) = Ω x)
    ∧ (∀ x : State, OperationalEq Observables (O x) x)
    ∧ (∀ {x y : State},
          OperationalEq Observables x y →
          OperationalEq Observables (O x) (O y))
    ∧ (∀ (n : Nat) (x : State),
          Ω (LawfulTrajectory O n x) = Ω x)
    ∧ (∀ (n : Nat) (x : State),
          OperationalEq Observables (LawfulTrajectory O n x) x)
    ∧ (∀ x : State, OperationalEq Observables (re (pi x)) x)
    ∧ (∀ x : State, OperationalEq Observables (re (pi (O x))) (O x)) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact governor_sound Ω hO
  · exact governor_preserves_declared_information Ω Observables hfactor hO
  · intro x y hxy
    exact quotient_descent Ω Observables hfactor hO hxy
  · exact lawfulTrajectory_preserves_invariant Ω hO
  · exact lawfulTrajectory_preserves_declared_information Ω Observables hfactor hO
  · exact reconstruction_modulo_observables Observables pi re hR
  · exact constitutional_roundtrip Ω Observables pi re hR hO

theorem reconstruction_is_operational_not_microscopic
    {State : Type u} {Obs : Type w}
    (Observables : (State → Obs) → Prop)
    (pi re : State → State)
    (hR : ReconstructionCorrect Observables pi re) :
    ∀ x : State, OperationalEq Observables (re (pi x)) x :=
  hR

def ExplicitFormulaBridgeTarget {Quot : Type v}
    (_ArithmeticMeasure : Quot → Quot) : Prop :=
  True

def InvariantCompletenessTarget {State : Type u} {Quot : Type v} {Obs : Type w}
    (Ω : State → Quot) (Observables : (State → Obs) → Prop) : Prop :=
  ∀ x y : State, Ω x = Ω y → OperationalEq Observables x y

theorem completeness_implies_operational_equivalence
    {State : Type u} {Quot : Type v} {Obs : Type w}
    (Ω : State → Quot) (Observables : (State → Obs) → Prop)
    (hcomplete : InvariantCompletenessTarget Ω Observables)
    {x y : State}
    (hΩ : Ω x = Ω y) :
    OperationalEq Observables x y :=
  hcomplete x y hΩ

end Chronofold.AGDSIC
