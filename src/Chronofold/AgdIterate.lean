import Chronofold.AgdClosure

/-!
# Tier A4 — Admission preserved under iteration
Lean 4.29 accepted — no sorries.
-/

namespace Chronofold.AGD

universe u

def opIterate (α : Type u) (T : Operator α) : Nat → Operator α
  | 0 => id
  | n + 1 => fun s => T (opIterate α T n s)

theorem opIterate_zero (α : Type u) (T : Operator α) (s : State α) :
    opIterate α T 0 s = s := rfl

theorem opIterate_succ (α : Type u) (T : Operator α) (n : Nat) (s : State α) :
    opIterate α T (n + 1) s = T (opIterate α T n s) := rfl

theorem admissible_id (α : Type u) (Ω : Omega α) (C : Covariant α) :
    Admissible α Ω C (id : Operator α) := by
  intro s
  constructor <;> rfl

theorem admissible_iterate (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T) :
    ∀ n, Admissible α Ω C (opIterate α T n) := by
  intro n
  induction n with
  | zero =>
      exact admissible_id α Ω C
  | succ n ih =>
      intro s
      have hPrev := ih s
      have hStep := hT (opIterate α T n s)
      constructor
      · calc Ω (opIterate α T (n + 1) s)
            = Ω (T (opIterate α T n s)) := by rw [opIterate_succ]
          _ = Ω (opIterate α T n s) := hStep.1
          _ = Ω s := hPrev.1
      · calc C (opIterate α T (n + 1) s)
            = C (T (opIterate α T n s)) := by rw [opIterate_succ]
          _ = C (opIterate α T n s) := hStep.2
          _ = C s := hPrev.2

theorem TBar_iterate_sound (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T) (n : Nat) (s : State α) :
    let hN := admissible_iterate α Ω C T hT n
    TBar α Ω C (opIterate α T n) hN (pi α Ω C s) = pi α Ω C (opIterate α T n s) :=
  TBar_sound α Ω C (opIterate α T n) (admissible_iterate α Ω C T hT n) s

end Chronofold.AGD
