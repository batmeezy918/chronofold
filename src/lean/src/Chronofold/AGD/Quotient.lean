import Chronofold.AGD.Core
namespace Chronofold
section Quotient
variable {S : Type*} (Q : S → Type*)
def equivalent_behavior (s1 s2 : S) (O1 : S → S) (O2 : S → S) : Prop :=
  ∃ (q : S → Type*), q s1 = q s2 ∧ q (O1 s1) = q (O2 s2)
end Quotient
end Chronofold
