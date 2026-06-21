namespace Chronofold
structure State where
  val : Nat
  stable : Bool
  stage : Nat
def operator_transition (s : State) : State :=
  if s.stage < 6 then { val := s.val, stable := true, stage := s.stage + 1 } else s
theorem workflow_stability (s : State) (h : s.stable = true) :
  (operator_transition s).stable = true := by
  unfold operator_transition
  split <;> simp [*]
end Chronofold
