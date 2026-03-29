namespace Chronofold

def H := Nat → Int

def Ω (x : H) : Int := x 0
def Ξ (x : H) : Int := x 2 - 2 * x 1 + x 0

def SNAP (x : H) : H :=
  fun i =>
    match i with
    | 0 => x 0
    | 1 => x 1 + 1
    | 2 => 2 * (x 1 + 1) - x 0 + Ξ x
    | _ => x i

def O_write := SNAP
def O_build := SNAP
def O_push := SNAP
def O_CI := SNAP

def O_pipeline :=
  O_CI ∘ O_push ∘ O_build ∘ O_write

theorem pipeline_invariants :
  ∀ x : H,
    Ω (O_pipeline x) = Ω x ∧
    Ξ (O_pipeline x) = Ξ x := by
  intro x
  unfold O_pipeline O_CI O_push O_build O_write
  repeat
    (first
      | simp [SNAP, Ω]
      | simp [SNAP, Ξ])
  exact And.intro rfl rfl

end Chronofold
