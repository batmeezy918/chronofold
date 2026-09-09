import Chronofold.SIM2XR_Universal_Costless_Logic

/-!
# AGD-GEMM Projection Correctness

Intertwining and observable preservation are explicit hypotheses.
This file does not prove that any particular GEMM projection is correct.
Lean 4 core. No Mathlib. No sorry. No extra axioms.
-/

namespace Chronofold.AGDGemmProjection

open SIM2XR.UniversalCostless

universe u v w

/-- One-step intertwining is SIM2XR descent. -/
def Intertwines {State : Type u} {Reduced : Type v}
    (T : State → State) (Tbar : Reduced → Reduced) (π : State → Reduced) : Prop :=
  Descends π T Tbar

/-- Observables that factor through the projection. -/
def ObservablePreserved {State : Type u} {Reduced : Type v} {Obs : Type w}
    (π : State → Reduced) (observe : State → Obs) (observeReduced : Reduced → Obs) : Prop :=
  ∀ x, observe x = observeReduced (π x)

theorem projection_step {State : Type u} {Reduced : Type v}
    (T : State → State) (Tbar : Reduced → Reduced) (π : State → Reduced)
    (h : Intertwines T Tbar π) :
    ∀ x, π (T x) = Tbar (π x) :=
  h

theorem observable_equivalence {State : Type u} {Reduced : Type v} {Obs : Type w}
    (π : State → Reduced) (observe : State → Obs) (observeReduced : Reduced → Obs)
    (h : ObservablePreserved π observe observeReduced) :
    ∀ x, observe x = observeReduced (π x) :=
  h

/-- Projection commutes with every finite execution. -/
theorem projection_iterate {State : Type u} {Reduced : Type v}
    (T : State → State) (Tbar : Reduced → Reduced) (π : State → Reduced)
    (h : Intertwines T Tbar π) :
    ∀ n x, π (iterate T n x) = iterate Tbar n (π x) :=
  (descends_iff_recursive π T Tbar).mp h

/-- If intertwining and observable preservation hold, every finite run
    exposes the same observable on the quotient. -/
theorem quotient_observable_correct {State : Type u} {Reduced : Type v} {Obs : Type w}
    (T : State → State) (Tbar : Reduced → Reduced) (π : State → Reduced)
    (observe : State → Obs) (observeReduced : Reduced → Obs)
    (hI : Intertwines T Tbar π)
    (hO : ObservablePreserved π observe observeReduced) :
    ∀ n x, observe (iterate T n x) = observeReduced (iterate Tbar n (π x)) := by
  intro n x
  calc
    observe (iterate T n x)
        = observeReduced (π (iterate T n x)) := hO (iterate T n x)
    _   = observeReduced (iterate Tbar n (π x)) := by
            rw [projection_iterate T Tbar π hI n x]

/-- Intertwining is necessary as well as sufficient for iterated commutation. -/
theorem intertwines_iff_iterate {State : Type u} {Reduced : Type v}
    (T : State → State) (Tbar : Reduced → Reduced) (π : State → Reduced) :
    Intertwines T Tbar π ↔
      ∀ n x, π (iterate T n x) = iterate Tbar n (π x) :=
  descends_iff_recursive π T Tbar

/-- Packaged projection closure. Hypotheses remain obligations for a concrete GEMM π. -/
theorem projection_closure {State : Type u} {Reduced : Type v} {Obs : Type w}
    (T : State → State) (Tbar : Reduced → Reduced) (π : State → Reduced)
    (observe : State → Obs) (observeReduced : Reduced → Obs)
    (hI : Intertwines T Tbar π)
    (hO : ObservablePreserved π observe observeReduced) :
    (∀ x, π (T x) = Tbar (π x)) ∧
    (∀ n x, π (iterate T n x) = iterate Tbar n (π x)) ∧
    (∀ n x, observe (iterate T n x) = observeReduced (iterate Tbar n (π x))) :=
  ⟨projection_step T Tbar π hI,
   projection_iterate T Tbar π hI,
   quotient_observable_correct T Tbar π observe observeReduced hI hO⟩

end Chronofold.AGDGemmProjection
