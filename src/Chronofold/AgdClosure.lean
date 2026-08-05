import Chronofold.AgdInvariants

/-!
# AGD Closure — compositional stability of admission

If T and S are admissible, so is S ∘ T.
-/

namespace Chronofold.AGD

universe u

theorem admissible_compose (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T S : Operator α)
    (hT : Admissible α Ω C T) (hS : Admissible α Ω C S) :
    Admissible α Ω C (fun s => S (T s)) := by
  intro s
  have hT' := hT s
  have hS' := hS (T s)
  constructor
  · calc Ω (S (T s))
        = Ω (T s) := hS'.1
      _ = Ω s := hT'.1
  · calc C (S (T s))
        = C (T s) := hS'.2
      _ = C s := hT'.2

end Chronofold.AGD
