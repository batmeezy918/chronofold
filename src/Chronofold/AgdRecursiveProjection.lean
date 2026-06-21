import Chronofold.AgdCore
import Mathlib.Tactic

namespace AGD

/- THEOREM 4 — RECURSIVE COMPRESSION CLOSURE -/

def is_projection_admissible (P : AgdState → AgdState) : Prop :=
  ∀ s1 s2, s1.data = s2.data → (P s1).data = (P s2).data

def projection_chain (projections : List (AgdState → AgdState)) : AgdState → AgdState :=
  match projections with
  | [] => id
  | p :: ps => (projection_chain ps) ∘ p

theorem AGD_Recursive_Compression_Closure
  (projections : List (AgdState → AgdState))
  (h_all_adm : ∀ p, p ∈ projections → is_projection_admissible p) :
  is_projection_admissible (projection_chain projections) := by
  induction projections with
  | nil =>
    unfold projection_chain is_projection_admissible
    simp
  | cons p ps ih =>
    unfold projection_chain
    have hp : is_projection_admissible p := h_all_adm p (by simp)
    have hps : ∀ p', p' ∈ ps → is_projection_admissible p' := fun p' hp' ↦ h_all_adm p' (by simp [hp'])
    have ih_adm : is_projection_admissible (projection_chain ps) := ih hps
    unfold is_projection_admissible at *
    intro s1 s2 heq
    simp
    apply ih_adm
    apply hp
    exact heq

end AGD
