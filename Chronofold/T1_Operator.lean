import Chronofold.Operators

namespace Chronofold

def T_Xi (θ : Float) : Operator :=
  fun s => Xi (Delta (S s))

def evolve (θ : Float) (s : State) : State :=
  T_Xi θ s

theorem T1_closed (θ : Float) :
  ∃ O : Operator, ∀ s, O s = evolve θ s := by
  refine ⟨T_Xi θ, ?_⟩
  intro s
  rfl

end Chronofold
