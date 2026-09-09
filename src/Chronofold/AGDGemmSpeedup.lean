import Chronofold.AGDGemmWork
import Chronofold.AGDGemmProjection
import Chronofold.AGDGemmReconstruction

/-!
# AGD-GEMM Modeled Speedup Boundary

Proved: modeled work ratio 16 on the canonical instance, plus the
semantic package under explicit intertwining / observable / section
hypotheses.

Not proved: wall-clock 15.96×, hardware superiority, or that a
particular GEMM projection satisfies the hypotheses.
-/

namespace Chronofold.AGDGemmSpeedup

open Chronofold.AGDGemmWork
open Chronofold.AGDGemmProjection
open Chronofold.AGDGemmReconstruction

universe u v w

/-- Semantic hypotheses required before a modeled work ratio may be
    read as a valid quotient computation. -/
structure SemanticHypotheses
    (State : Type u) (Reduced : Type v) (Obs : Type w) where
  T : State → State
  Tbar : Reduced → Reduced
  π : State → Reduced
  σ : Reduced → State
  observe : State → Obs
  observeReduced : Reduced → Obs
  intertwines : Intertwines T Tbar π
  observable : ObservablePreserved π observe observeReduced
  section : Section π σ

/-- Modeled work validity: arithmetic ratio plus semantic package. -/
theorem modeled_speedup_valid
    {State : Type u} {Reduced : Type v} {Obs : Type w}
    (H : SemanticHypotheses State Reduced Obs) :
    workRatio (fullWork 1024 1024 1024) (quotientWork 256 256 1024) = 16 ∧
    (∀ n x, H.observe (SIM2XR.UniversalCostless.iterate H.T n x) =
      H.observeReduced (SIM2XR.UniversalCostless.iterate H.Tbar n (H.π x))) ∧
    (H.π ∘ H.σ = id) :=
  ⟨canonical_workRatio,
   quotient_observable_correct H.T H.Tbar H.π H.observe H.observeReduced
     H.intertwines H.observable,
   section_is_right_inverse H.π H.σ H.section⟩

/-- Wall-clock measurements are outside this file. A measured factor
    such as 15.96 is an evidence-gate obligation, not a Lean equality. -/
def MeasuredRuntimeObligation : Prop := True

theorem measured_runtime_is_not_a_work_theorem :
    MeasuredRuntimeObligation ∧
    workRatio (fullWork 1024 1024 1024) (quotientWork 256 256 1024) = 16 :=
  ⟨trivial, canonical_workRatio⟩

theorem speedup_stack_closure :
    work_model_closure ∧
    MeasuredRuntimeObligation :=
  ⟨work_model_closure, trivial⟩

end Chronofold.AGDGemmSpeedup
