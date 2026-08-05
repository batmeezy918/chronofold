import Chronofold.AgdOperators

/-!
# Tier A2 — Multi-invariant constitution
Lean 4.29 accepted — no sorries.
-/

namespace Chronofold.AGD

universe u

def MultiOmega (alpha : Type u) (n : Nat) := State alpha → Fin n → Nat

def mixNat (a b : Nat) : Nat := a * 65599 + b

def MultiEquiv {alpha : Type u} {n : Nat} (M : MultiOmega alpha n) (C : Covariant alpha)
    (s1 s2 : State alpha) : Prop :=
  (∀ i : Fin n, M s1 i = M s2 i) ∧ C s1 = C s2

theorem MultiEquiv.refl {alpha : Type u} {n : Nat} (M : MultiOmega alpha n) (C : Covariant alpha)
    (s : State alpha) : MultiEquiv M C s s :=
  ⟨fun _ => rfl, rfl⟩

theorem MultiEquiv.symm {alpha : Type u} {n : Nat} (M : MultiOmega alpha n) (C : Covariant alpha)
    {s1 s2 : State alpha} (h : MultiEquiv M C s1 s2) : MultiEquiv M C s2 s1 :=
  ⟨fun i => (h.1 i).symm, h.2.symm⟩

theorem MultiEquiv.trans {alpha : Type u} {n : Nat} (M : MultiOmega alpha n) (C : Covariant alpha)
    {s1 s2 s3 : State alpha} (h12 : MultiEquiv M C s1 s2) (h23 : MultiEquiv M C s2 s3) :
    MultiEquiv M C s1 s3 :=
  ⟨fun i => (h12.1 i).trans (h23.1 i), h12.2.trans h23.2⟩

def multiSetoid {alpha : Type u} {n : Nat} (M : MultiOmega alpha n) (C : Covariant alpha) :
    Setoid (State alpha) where
  r := MultiEquiv M C
  iseqv := ⟨MultiEquiv.refl M C, MultiEquiv.symm M C, MultiEquiv.trans M C⟩

def QStarMulti {alpha : Type u} {n : Nat} (M : MultiOmega alpha n) (C : Covariant alpha) :
    Type u :=
  Quotient (multiSetoid M C)

def piMulti {alpha : Type u} {n : Nat} (M : MultiOmega alpha n) (C : Covariant alpha) :
    State alpha → QStarMulti M C :=
  Quotient.mk (multiSetoid M C)

def dropLast {alpha : Type u} {n : Nat} (M : MultiOmega alpha (n + 1)) :
    MultiOmega alpha n :=
  fun s i => M s i.castSucc

theorem multiEquiv_of_finer {alpha : Type u} {n : Nat}
    (M : MultiOmega alpha (n + 1)) (C : Covariant alpha) {s1 s2 : State alpha}
    (h : MultiEquiv M C s1 s2) :
    MultiEquiv (dropLast M) C s1 s2 :=
  ⟨fun i => h.1 i.castSucc, h.2⟩

def MultiAdmissible {alpha : Type u} {n : Nat} (M : MultiOmega alpha n) (C : Covariant alpha)
    (T : Operator alpha) : Prop :=
  ∀ s, (∀ i, M (T s) i = M s i) ∧ C (T s) = C s

theorem multiAdmissible_compose {alpha : Type u} {n : Nat}
    (M : MultiOmega alpha n) (C : Covariant alpha) (T S : Operator alpha)
    (hT : MultiAdmissible M C T) (hS : MultiAdmissible M C S) :
    MultiAdmissible M C (fun s => S (T s)) := by
  intro s
  have hT' := hT s
  have hS' := hS (T s)
  constructor
  · intro i
    calc M (S (T s)) i = M (T s) i := hS'.1 i
      _ = M s i := hT'.1 i
  · calc C (S (T s)) = C (T s) := hS'.2
      _ = C s := hT'.2

theorem finer_implies_coarser {alpha : Type u} {n : Nat}
    (M : MultiOmega alpha (n + 1)) (C : Covariant alpha) (s1 s2 : State alpha) :
    MultiEquiv M C s1 s2 → MultiEquiv (dropLast M) C s1 s2 :=
  multiEquiv_of_finer M C

end Chronofold.AGD
