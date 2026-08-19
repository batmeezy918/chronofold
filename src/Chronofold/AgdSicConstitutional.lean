/-!
# AGD x SIC - Elevated Constitutional Closure
Version: 1.0 (Lean 4.29, Chronofold package, no Mathlib)

All theorems proved with no sorry.
Observables encoded as predicate (State -> Obs) -> Prop (no Mathlib Set).
Projection/reconstruction binders use ASCII pi/re (Lean Pi is a binder keyword).
-/

namespace Chronofold.AGDSIC

universe u v w

def OperationalEq {State : Type u} {Obs : Type w}
    (Observables : (State -> Obs) -> Prop) (x y : State) : Prop :=
  forall (f : State -> Obs), Observables f -> f x = f y

theorem operationalEq_refl {State : Type u} {Obs : Type w}
    (Observables : (State -> Obs) -> Prop) (x : State) :
    OperationalEq Observables x x := by
  intro f hf; rfl

theorem operationalEq_symm {State : Type u} {Obs : Type w}
    (Observables : (State -> Obs) -> Prop) {x y : State}
    (hxy : OperationalEq Observables x y) :
    OperationalEq Observables y x := by
  intro f hf; exact (hxy f hf).symm

theorem operationalEq_trans {State : Type u} {Obs : Type w}
    (Observables : (State -> Obs) -> Prop) {x y z : State}
    (hxy : OperationalEq Observables x y)
    (hyz : OperationalEq Observables y z) :
    OperationalEq Observables x z := by
  intro f hf; exact (hxy f hf).trans (hyz f hf)

theorem operationalEq_equivalence {State : Type u} {Obs : Type w}
    (Observables : (State -> Obs) -> Prop) :
    Equivalence (OperationalEq Observables) :=
  ⟨operationalEq_refl Observables,
   fun {_ _} h => operationalEq_symm Observables h,
   fun {_ _ _} hxy hyz => operationalEq_trans Observables hxy hyz⟩

def ObservableFactorsThroughInvariant {State : Type u} {Quot : Type v} {Obs : Type w}
    (Omega : State -> Quot) (Observables : (State -> Obs) -> Prop) : Prop :=
  forall (f : State -> Obs), Observables f ->
    exists g : Quot -> Obs, forall x : State, f x = g (Omega x)

def InvariantPreserving {State : Type u} {Quot : Type v}
    (Omega : State -> Quot) (O : State -> State) : Prop :=
  forall x : State, Omega (O x) = Omega x

theorem invariant_identity {State : Type u} {Quot : Type v}
    (Omega : State -> Quot) :
    InvariantPreserving Omega (fun x => x) := by intro x; rfl

theorem invariant_comp {State : Type u} {Quot : Type v}
    (Omega : State -> Quot) {O1 O2 : State -> State}
    (h1 : InvariantPreserving Omega O1)
    (h2 : InvariantPreserving Omega O2) :
    InvariantPreserving Omega (O2 circ O1) := by
  intro x
  exact (h2 (O1 x)).trans (h1 x)

def SICOperatorAlgebra {State : Type u} {Quot : Type v}
    (Omega : State -> Quot) (O : State -> State) : Prop :=
  InvariantPreserving Omega O

theorem SICOperatorAlgebra_id {State : Type u} {Quot : Type v}
    (Omega : State -> Quot) :
    SICOperatorAlgebra Omega (fun x : State => x) :=
  invariant_identity Omega

theorem SICOperatorAlgebra_comp {State : Type u} {Quot : Type v}
    (Omega : State -> Quot) {O1 O2 : State -> State}
    (h1 : SICOperatorAlgebra Omega O1)
    (h2 : SICOperatorAlgebra Omega O2) :
    SICOperatorAlgebra Omega (O2 circ O1) :=
  invariant_comp Omega h1 h2

theorem invariant_preservation_implies_operational_equivalence
    {State : Type u} {Quot : Type v} {Obs : Type w}
    (Omega : State -> Quot) (Observables : (State -> Obs) -> Prop)
    (hfactor : ObservableFactorsThroughInvariant Omega Observables)
    {O : State -> State}
    (hOmega : InvariantPreserving Omega O) :
    forall x : State, OperationalEq Observables (O x) x := by
  intro x f hf
  obtain ⟨g, hg⟩ := hfactor f hf
  rw [hg (O x), hg x, hOmega x]

def Governor {State : Type u} {Quot : Type v}
    (Omega : State -> Quot) (O : State -> State) : Prop :=
  InvariantPreserving Omega O

theorem governor_iff_invariant {State : Type u} {Quot : Type v}
    (Omega : State -> Quot) {O : State -> State} :
    Governor Omega O <-> InvariantPreserving Omega O := Iff.rfl

theorem governor_sound {State : Type u} {Quot : Type v}
    (Omega : State -> Quot) {O : State -> State}
    (hO : Governor Omega O) :
    forall x : State, Omega (O x) = Omega x := hO

theorem governor_identity {State : Type u} {Quot : Type v}
    (Omega : State -> Quot) :
    Governor Omega (fun x => x) := invariant_identity Omega

theorem governor_composition_closed {State : Type u} {Quot : Type v}
    (Omega : State -> Quot) {O1 O2 : State -> State}
    (h1 : Governor Omega O1) (h2 : Governor Omega O2) :
    Governor Omega (O2 circ O1) := invariant_comp Omega h1 h2

theorem governor_generates_closed_operator_system
    {State : Type u} {Quot : Type v}
    (Omega : State -> Quot) {O1 O2 : State -> State}
    (h1 : Governor Omega O1) (h2 : Governor Omega O2) :
    Governor Omega (O2 circ O1) /\ Governor Omega (fun x => x) :=
  ⟨governor_composition_closed Omega h1 h2, governor_identity Omega⟩

theorem governor_preserves_declared_information
    {State : Type u} {Quot : Type v} {Obs : Type w}
    (Omega : State -> Quot) (Observables : (State -> Obs) -> Prop)
    (hfactor : ObservableFactorsThroughInvariant Omega Observables)
    {O : State -> State}
    (hO : Governor Omega O) :
    forall x : State, OperationalEq Observables (O x) x :=
  invariant_preservation_implies_operational_equivalence Omega Observables hfactor hO

theorem quotient_descent
    {State : Type u} {Quot : Type v} {Obs : Type w}
    (Omega : State -> Quot) (Observables : (State -> Obs) -> Prop)
    (hfactor : ObservableFactorsThroughInvariant Omega Observables)
    {O : State -> State}
    (hO : Governor Omega O)
    {x y : State}
    (hxy : OperationalEq Observables x y) :
    OperationalEq Observables (O x) (O y) := by
  intro f hf
  have hx : f (O x) = f x :=
    governor_preserves_declared_information Omega Observables hfactor hO x f hf
  have hy : f (O y) = f y :=
    governor_preserves_declared_information Omega Observables hfactor hO y f hf
  exact hx.trans ((hxy f hf).trans hy.symm)

def ReconstructionCorrect {State : Type u} {Obs : Type w}
    (Observables : (State -> Obs) -> Prop)
    (pi re : State -> State) : Prop :=
  forall x : State, OperationalEq Observables (re (pi x)) x

theorem reconstruction_modulo_observables
    {State : Type u} {Obs : Type w}
    (Observables : (State -> Obs) -> Prop)
    (pi re : State -> State)
    (hR : ReconstructionCorrect Observables pi re) :
    forall x : State, OperationalEq Observables (re (pi x)) x := hR

theorem reconstruction_preserves_declared_information
    {State : Type u} {Obs : Type w}
    (Observables : (State -> Obs) -> Prop)
    (pi re : State -> State)
    (hR : ReconstructionCorrect Observables pi re)
    {f : State -> Obs}
    (hf : Observables f) :
    forall x : State, f (re (pi x)) = f x := by
  intro x; exact hR x f hf

def ReplayCorrect {State : Type u} {Obs : Type w}
    (Observables : (State -> Obs) -> Prop)
    (Replay : State -> State) : Prop :=
  forall x : State, OperationalEq Observables (Replay x) x

theorem replay_preserves_declared_information
    {State : Type u} {Obs : Type w}
    (Observables : (State -> Obs) -> Prop)
    {Replay : State -> State}
    (hReplay : ReplayCorrect Observables Replay) :
    forall x : State, OperationalEq Observables (Replay x) x := hReplay

theorem constitutional_roundtrip
    {State : Type u} {Quot : Type v} {Obs : Type w}
    (Omega : State -> Quot)
    (Observables : (State -> Obs) -> Prop)
    (pi re : State -> State)
    (hR : ReconstructionCorrect Observables pi re)
    {O : State -> State}
    (_hO : Governor Omega O) :
    forall x : State, OperationalEq Observables (re (pi (O x))) (O x) := by
  intro x; exact hR (O x)

def LawfulTrajectory {State : Type u}
    (O : State -> State) : Nat -> State -> State
  | 0,     x => x
  | n + 1, x => O (LawfulTrajectory O n x)

theorem lawfulTrajectory_preserves_invariant
    {State : Type u} {Quot : Type v}
    (Omega : State -> Quot)
    {O : State -> State}
    (hO : Governor Omega O) :
    forall (n : Nat) (x : State),
      Omega (LawfulTrajectory O n x) = Omega x := by
  intro n; induction n with
  | zero => intro x; rfl
  | succ n ih =>
      intro x
      exact (hO (LawfulTrajectory O n x)).trans (ih x)

theorem lawfulTrajectory_preserves_declared_information
    {State : Type u} {Quot : Type v} {Obs : Type w}
    (Omega : State -> Quot)
    (Observables : (State -> Obs) -> Prop)
    (hfactor : ObservableFactorsThroughInvariant Omega Observables)
    {O : State -> State}
    (hO : Governor Omega O) :
    forall (n : Nat) (x : State),
      OperationalEq Observables (LawfulTrajectory O n x) x := by
  intro n x
  have htraj : InvariantPreserving Omega (LawfulTrajectory O n) := by
    intro y; exact lawfulTrajectory_preserves_invariant Omega hO n y
  exact invariant_preservation_implies_operational_equivalence
    Omega Observables hfactor htraj x

theorem sic_agd_constitutional_closure
    {State : Type u} {Quot : Type v} {Obs : Type w}
    (Omega : State -> Quot)
    (Observables : (State -> Obs) -> Prop)
    (pi re : State -> State)
    (hfactor : ObservableFactorsThroughInvariant Omega Observables)
    (hR : ReconstructionCorrect Observables pi re)
    {O : State -> State}
    (hO : Governor Omega O) :
    (forall x : State, Omega (O x) = Omega x)
    /\ (forall x : State, OperationalEq Observables (O x) x)
    /\ (forall {x y : State},
          OperationalEq Observables x y ->
          OperationalEq Observables (O x) (O y))
    /\ (forall (n : Nat) (x : State),
          Omega (LawfulTrajectory O n x) = Omega x)
    /\ (forall (n : Nat) (x : State),
          OperationalEq Observables (LawfulTrajectory O n x) x)
    /\ (forall x : State, OperationalEq Observables (re (pi x)) x)
    /\ (forall x : State, OperationalEq Observables (re (pi (O x))) (O x)) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact governor_sound Omega hO
  · exact governor_preserves_declared_information Omega Observables hfactor hO
  · intro x y hxy; exact quotient_descent Omega Observables hfactor hO hxy
  · exact lawfulTrajectory_preserves_invariant Omega hO
  · exact lawfulTrajectory_preserves_declared_information Omega Observables hfactor hO
  · exact reconstruction_modulo_observables Observables pi re hR
  · exact constitutional_roundtrip Omega Observables pi re hR hO

theorem reconstruction_is_operational_not_microscopic
    {State : Type u} {Obs : Type w}
    (Observables : (State -> Obs) -> Prop)
    (pi re : State -> State)
    (hR : ReconstructionCorrect Observables pi re) :
    forall x : State, OperationalEq Observables (re (pi x)) x := hR

def ExplicitFormulaBridgeTarget {Quot : Type v}
    (_ArithmeticMeasure : Quot -> Quot) : Prop := True

def InvariantCompletenessTarget {State : Type u} {Quot : Type v} {Obs : Type w}
    (Omega : State -> Quot) (Observables : (State -> Obs) -> Prop) : Prop :=
  forall x y : State, Omega x = Omega y -> OperationalEq Observables x y

theorem completeness_implies_operational_equivalence
    {State : Type u} {Quot : Type v} {Obs : Type w}
    (Omega : State -> Quot) (Observables : (State -> Obs) -> Prop)
    (hcomplete : InvariantCompletenessTarget Omega Observables)
    {x y : State}
    (hOmega : Omega x = Omega y) :
    OperationalEq Observables x y := hcomplete x y hOmega

end Chronofold.AGDSIC
