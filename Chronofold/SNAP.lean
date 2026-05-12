def H := Nat → Int

def Ω (x : H) : Int := x 0
def Ξ (x : H) : Int := x 2 - 2 * x 1 + x 0
def Δ (x : H) : Int := 1

def SNAP (x : H) : H :=
  fun i =>
    match i with
    | 0 => x 0
    | 1 => x 1 + Δ x
    | 2 => 2 * (x 1 + Δ x) - x 0 + Ξ x
    | _ => x i

theorem SNAP_invariants :
  ∀ x : H, Ω (SNAP x) = Ω x ∧ Ξ (SNAP x) = Ξ x := by
  intro x
  constructor
  · unfold Ω SNAP; simp
  · unfold Ξ SNAP; simp

end Chronofold
