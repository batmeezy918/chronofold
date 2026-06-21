namespace Chronofold
structure State where
  val : Nat
  stable : Bool
  stage : Nat
def operator_transition (s : State) : State :=
  if s.stage < 6 then { val := s.val, stable := true, stage := s.stage + 1 } else s
theorem stage_ordering (s : State) (h : s.stage < 6) :
  (operator_transition s).stage = s.stage + 1 := by
  unfold operator_transition
  simp [h]
end Chronofold
