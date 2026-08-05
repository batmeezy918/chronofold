import Chronofold.AgdMultiOmega

/-!
# Invariant Safety

A constitution (Ω, C) is **invariant-safe** relative to critical observables if
it never places two critically-distinguished states in the same AGD class.

Lean 4.29 — no sorries.
-/

namespace Chronofold.AGD

universe u

abbrev CriticalObs (α : Type u) := State α → Nat

def invariantSafe (α : Type u) (Ω : Omega α) (C : Covariant α)
    (criticals : List (CriticalObs α)) : Prop :=
  ∀ s₁ s₂ : State α,
    (∃ f ∈ criticals, f s₁ ≠ f s₂) → ¬ AGDEquiv α Ω C s₁ s₂

def invariantSafe' (α : Type u) (Ω : Omega α) (C : Covariant α)
    (criticals : List (CriticalObs α)) : Prop :=
  ∀ s₁ s₂ : State α,
    AGDEquiv α Ω C s₁ s₂ → ∀ f ∈ criticals, f s₁ = f s₂

theorem invariantSafe'_of_safe (α : Type u) (Ω : Omega α) (C : Covariant α)
    (criticals : List (CriticalObs α))
    (h : invariantSafe α Ω C criticals) :
    invariantSafe' α Ω C criticals := by
  intro s₁ s₂ heq f hf
  cases Classical.em (f s₁ = f s₂) with
  | inl heqfc => exact heqfc
  | inr hne =>
      exact False.elim (h s₁ s₂ ⟨f, hf, hne⟩ heq)

theorem invariantSafe_of_safe' (α : Type u) (Ω : Omega α) (C : Covariant α)
    (criticals : List (CriticalObs α))
    (h : invariantSafe' α Ω C criticals) :
    invariantSafe α Ω C criticals := by
  intro s₁ s₂ ⟨f, hf, hne⟩ heq
  exact hne (h s₁ s₂ heq f hf)

theorem invariantSafe_iff (α : Type u) (Ω : Omega α) (C : Covariant α)
    (criticals : List (CriticalObs α)) :
    invariantSafe α Ω C criticals ↔ invariantSafe' α Ω C criticals :=
  ⟨invariantSafe'_of_safe α Ω C criticals, invariantSafe_of_safe' α Ω C criticals⟩

theorem invariantSafe_nil (α : Type u) (Ω : Omega α) (C : Covariant α) :
    invariantSafe α Ω C [] := by
  intro s₁ s₂ ⟨_f, hf, _⟩
  cases hf

theorem invariantSafe_of_criticals_in_constitution
    (α : Type u) (Ω : Omega α) (C : Covariant α)
    (criticals : List (CriticalObs α))
    (hsub : ∀ f ∈ criticals, f = Ω ∨ f = C) :
    invariantSafe α Ω C criticals := by
  intro s₁ s₂ ⟨f, hf, hne⟩ heq
  cases hsub f hf with
  | inl hΩ =>
      have hΩeq : Ω s₁ = Ω s₂ := heq.1
      exact hne (hΩ ▸ hΩeq)
  | inr hC =>
      have hCeq : C s₁ = C s₂ := heq.2
      exact hne (hC ▸ hCeq)

theorem invariantSafe_omega (α : Type u) (Ω : Omega α) (C : Covariant α) :
    invariantSafe α Ω C [Ω] :=
  invariantSafe_of_criticals_in_constitution α Ω C [Ω] (by
    intro f hf
    have : f = Ω := List.mem_singleton.mp hf
    exact Or.inl this)

theorem invariantSafe_C (α : Type u) (Ω : Omega α) (C : Covariant α) :
    invariantSafe α Ω C [C] :=
  invariantSafe_of_criticals_in_constitution α Ω C [C] (by
    intro f hf
    have : f = C := List.mem_singleton.mp hf
    exact Or.inr this)

theorem invariantSafe_omega_and_C (α : Type u) (Ω : Omega α) (C : Covariant α) :
    invariantSafe α Ω C [Ω, C] :=
  invariantSafe_of_criticals_in_constitution α Ω C [Ω, C] (by
    intro f hf
    have hmem : f = Ω ∨ f = C := List.mem_cons.mp hf |>.elim
      (fun h => Or.inl h)
      (fun h => Or.inr (List.mem_singleton.mp h))
    exact hmem)

theorem drop_critical_makes_unsafe
    (α : Type u) (Ω : Omega α) (C : Covariant α) (f : CriticalObs α)
    (s₁ s₂ : State α)
    (hdiff : f s₁ ≠ f s₂)
    (hsame : AGDEquiv α Ω C s₁ s₂) :
    ¬ invariantSafe α Ω C [f] := by
  intro hsafe
  exact hsafe s₁ s₂ ⟨f, List.mem_singleton.mpr rfl, hdiff⟩ hsame

def multiInvariantSafe {α : Type u} {n : Nat}
    (M : MultiOmega α n) (C : Covariant α)
    (criticals : List (CriticalObs α)) : Prop :=
  ∀ s₁ s₂ : State α,
    (∃ f ∈ criticals, f s₁ ≠ f s₂) → ¬ MultiEquiv M C s₁ s₂

theorem multiInvariantSafe_of_components
    {α : Type u} {n : Nat}
    (M : MultiOmega α n) (C : Covariant α)
    (criticals : List (CriticalObs α))
    (hsub : ∀ f ∈ criticals, (∃ i : Fin n, f = fun s => M s i) ∨ f = C) :
    multiInvariantSafe M C criticals := by
  intro s₁ s₂ ⟨f, hf, hne⟩ hEq
  cases hsub f hf with
  | inl hidx =>
      obtain ⟨i, hi⟩ := hidx
      have : M s₁ i = M s₂ i := hEq.1 i
      exact hne (hi ▸ this)
  | inr hC =>
      have : C s₁ = C s₂ := hEq.2
      exact hne (hC ▸ this)

theorem coarser_may_be_unsafe
    (α : Type u) (Ωcoarse : Omega α) (C : Covariant α) (f : CriticalObs α)
    (s₁ s₂ : State α)
    (hdiff : f s₁ ≠ f s₂)
    (hcoarse_collapse : AGDEquiv α Ωcoarse C s₁ s₂) :
    ¬ invariantSafe α Ωcoarse C [f] :=
  drop_critical_makes_unsafe α Ωcoarse C f s₁ s₂ hdiff hcoarse_collapse

def sampleAgreesOnCriticals (α : Type u)
    (Ω : Omega α) (C : Covariant α)
    (criticals : List (CriticalObs α))
    (s₁ s₂ : State α) : Bool :=
  if (Ω s₁ == Ω s₂) && (C s₁ == C s₂) then
    criticals.all (fun f => f s₁ == f s₂)
  else
    true

def checkSafeSample (α : Type u)
    (Ω : Omega α) (C : Covariant α)
    (criticals : List (CriticalObs α))
    (sample : List (State α)) : Bool :=
  sample.all fun s₁ =>
    sample.all fun s₂ =>
      sampleAgreesOnCriticals α Ω C criticals s₁ s₂

theorem checkSafeSample_implies_pairwise
    (α : Type u)
    (Ω : Omega α) (C : Covariant α)
    (criticals : List (CriticalObs α))
    (sample : List (State α))
    (h : checkSafeSample α Ω C criticals sample = true)
    (s₁ s₂ : State α)
    (hs₁ : s₁ ∈ sample) (hs₂ : s₂ ∈ sample)
    (heq : AGDEquiv α Ω C s₁ s₂) :
    ∀ f ∈ criticals, f s₁ = f s₂ := by
  have hall : sample.all (fun s₁ => sample.all (fun s₂ =>
      sampleAgreesOnCriticals α Ω C criticals s₁ s₂)) = true := h
  have h1 := List.all_eq_true.mp hall s₁ hs₁
  have h2 := List.all_eq_true.mp h1 s₂ hs₂
  have hΩ : Ω s₁ = Ω s₂ := heq.1
  have hC : C s₁ = C s₂ := heq.2
  simp [sampleAgreesOnCriticals, hΩ, hC, Bool.and_self] at h2
  exact h2

end Chronofold.AGD
