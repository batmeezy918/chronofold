import Chronofold.AgdBidirectional
import Chronofold.AgdInvariantSafety
import Chronofold.AgdUniversal
import Chronofold.AgdIterate

/-!
# Master Bidirectional Operational Closure

The missing bidirectional interface: class preservation is *equivalent*
to admissibility. Everything else in this module is a composition of
already-verified AGD lemmas (TBar soundness, iterate soundness,
reconstruction, universal factorization, invariant safety).

No `sorry`. No `admit`. No Mathlib. No numerical or physical claims.

Evidence boundary (do not promote past this):
- does **not** claim universal speedup, termination, optimizer dominance,
  external-world restoration, cryptographic power, or quantum advantage.
- GREEN only after `lake build Chronofold` accepts this module.
-/

namespace Chronofold.AGD

universe u v

/-- T preserves every AGD class: `π(T s) = π s`. -/
def PreservesClass (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) : Prop :=
  ∀ s, pi α Ω C (T s) = pi α Ω C s

/-- Admissible operators stay inside the fibre of every state. -/
theorem preservesClass_of_admissible
    (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T) :
    PreservesClass α Ω C T := by
  intro s
  exact Quotient.sound (admissible_preserves_class α Ω C T hT s)

/-- Class preservation implies observability preservation, hence admissibility.
This is the converse that was not previously a first-class theorem. -/
theorem admissible_of_preservesClass
    (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (h : PreservesClass α Ω C T) :
    Admissible α Ω C T := by
  intro s
  exact Quotient.exact (h s)

/-- **THE GAP CLOSURE.**
    `π(T s) = π s` for all `s`  if and only if  `T` is admissible. -/
theorem admissible_iff_preservesClass
    (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) :
    Admissible α Ω C T ↔ PreservesClass α Ω C T :=
  ⟨preservesClass_of_admissible α Ω C T,
   admissible_of_preservesClass α Ω C T⟩

/-- Unfolded form matching the staff landing declaration. -/
theorem admissible_iff_class_eq
    (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) :
    (∀ s, pi α Ω C (T s) = pi α Ω C s) ↔ Admissible α Ω C T :=
  (admissible_iff_preservesClass α Ω C T).symm

/-- Counterexample direction: a non-admissible operator leaves some class. -/
theorem not_admissible_breaks_class
    (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (h : ¬ Admissible α Ω C T) :
    ∃ s, pi α Ω C (T s) ≠ pi α Ω C s := by
  have hnp : ¬ PreservesClass α Ω C T :=
    fun hpc => h (admissible_of_preservesClass α Ω C T hpc)
  by_contra hnone
  apply hnp
  intro s
  by_contra hne
  exact hnone ⟨s, hne⟩

/-- Quotient equality is exactly equality of the retained constitution. -/
theorem constitution_iff_class
    (α : Type u) (Ω : Omega α) (C : Covariant α)
    (s₁ s₂ : State α) :
    pi α Ω C s₁ = pi α Ω C s₂ ↔ Ω s₁ = Ω s₂ ∧ C s₁ = C s₂ := by
  constructor
  · intro h
    exact Quotient.exact h
  · intro h
    exact Quotient.sound h

/-- Unique descended dynamics: any map that intertwines with `T` on `π`
    is the canonical `T̄`. -/
theorem TBar_unique
    (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T)
    (G : QStar α Ω C → QStar α Ω C)
    (hG : ∀ s, G (pi α Ω C s) = pi α Ω C (T s)) :
    G = TBar α Ω C T hT := by
  funext q
  refine Quotient.inductionOn q ?_
  intro s
  calc G (pi α Ω C s)
      = pi α Ω C (T s) := hG s
    _ = TBar α Ω C T hT (pi α Ω C s) :=
          (TBar_sound α Ω C T hT s).symm

/-- Master landing. Composition of verified interfaces plus the new iff. -/
theorem master_bidirectional_operational_closure
    (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) :
    ((∀ s, pi α Ω C (T s) = pi α Ω C s) ↔
      Admissible α Ω C T)
    ∧
    (∀ hT : Admissible α Ω C T,
      ∀ s,
        TBar α Ω C T hT (pi α Ω C s) =
        pi α Ω C (T s))
    ∧
    (∀ hT : Admissible α Ω C T,
      ∀ n s,
        TBar α Ω C (opIterate α T n)
          (admissible_iterate α Ω C T hT n)
          (pi α Ω C s) =
        pi α Ω C (opIterate α T n s))
    ∧
    (∀ q : QStar α Ω C,
      ∃ s : State α, pi α Ω C s = q)
    ∧
    (∀ (β : Type v) (f : State α → β),
      RespectsAGD α Ω C f →
      (∃ fbar : QStar α Ω C → β,
        ∀ s, fbar (pi α Ω C s) = f s) ∧
      (∀ g₁ g₂ : QStar α Ω C → β,
        (∀ s, g₁ (pi α Ω C s) = f s) →
        (∀ s, g₂ (pi α Ω C s) = f s) →
        g₁ = g₂))
    ∧
    invariantSafe α Ω C [Ω, C] := by
  refine ⟨?iff, ?sound, ?iter, ?recon, ?univ, ?safe⟩
  · exact admissible_iff_class_eq α Ω C T
  · intro hT s
    exact TBar_sound α Ω C T hT s
  · intro hT n s
    exact TBar_iterate_sound α Ω C T hT n s
  · intro q
    exact exists_reconstruct α Ω C q
  · intro β f hf
    exact qstar_universal α Ω C f hf
  · exact invariantSafe_omega_and_C α Ω C

end Chronofold.AGD
