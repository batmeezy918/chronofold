import Chronofold.Base

namespace Chronofold

def S : Operator := fun s => s
def Delta : Operator := fun s => s
def Xi : Operator := fun s => s

def comp (f g : Operator) : Operator :=
  fun s => f (g s)

theorem operator_closure (f g : Operator) :
  ∃ h : Operator, h = comp f g := by
  exact ⟨comp f g, rfl⟩

end Chronofold
