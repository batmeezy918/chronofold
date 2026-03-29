namespace Chronofold

def H := Nat → Int

-- invariants
def Ω (x : H) : Int := x 0
def Ξ (x : H) : Int := x 2 - 2 * x 1 + x 0

-- delta (adaptive step)
def Δ (x : H) : Int := 1

-- SNAP operator
def SNAP (x : H) : H :=
  fun i =>
    match i with
    | 0 => x 0
    | 1 => x 1 + Δ x
    | 2 => 2 * (x 1 + Δ x) - x 0 + Ξ x
    | _ => x i

-- theorem: invariants preserved
theorem SNAP_invariants :
  ∀ x : H, Ω (SNAP x) = Ω x ∧ Ξ (SNAP x) = Ξ x := by
  intro x
  constructor
  · unfold Ω SNAP
    simp
  · unfold Ξ SNAP
    simp

end Chronofold
