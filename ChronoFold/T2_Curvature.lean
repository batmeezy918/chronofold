namespace Chronofold

def H := Nat → Int

def Ξ (x : H) : Int :=
  x 2 - 2 * x 1 + x 0

def O (x : H) : H :=
  fun i =>
    match i with
    | 0 => x 0
    | 1 => x 1
    | 2 => 2 * x 1 - x 0 + Ξ x
    | _ => x i

theorem T2_curvature_preserved :
  ∀ x : H, Ξ (O x) = Ξ x := by
  intro x
  unfold Ξ O
  simp

end Chronofold
