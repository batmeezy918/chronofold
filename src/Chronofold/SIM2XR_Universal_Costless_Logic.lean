/-!
# SIM2XR Universal Costless Logic

Cost-independent operational equivalence.

This module separates *semantic* operational logic (projection, descent,
iteration, class preservation, induced quotient operators, uniqueness,
observable factorization, reconstruction) from *external realization cost*.
No theorem in the packaged closure takes a cost hypothesis.

Lean 4 core only. No Mathlib. No unfinished goals. No extra axioms. No placeholders.
-/

namespace SIM2XR.UniversalCostless

universe u v w

/-! ## Primitive semantic vocabulary -/

/-- Operational equivalence: agreement after the constitutional projection. -/
def Equivalent {α : Type u} {β : Type v} (π : α → β) (x y : α) : Prop :=
  π x = π y

/-- One-step descent: `π` intertwines `T` with `Tbar`. -/
def Descends {α : Type u} {β : Type v}
    (π : α → β) (T : α → α) (Tbar : β → β) : Prop :=
  ∀ x, π (T x) = Tbar (π x)

/-- Class preservation: every hidden state stays in its quotient class. -/
def PreservesClass {α : Type u} {β : Type v}
    (π : α → β) (T : α → α) : Prop :=
  ∀ x, Equivalent π (T x) x

/-- Fibre well-definedness of a hidden operator. -/
def WellDefined {α : Type u} {β : Type v}
    (π : α → β) (T : α → α) : Prop :=
  ∀ x y, π x = π y → π (T x) = π (T y)

/-- A section of `π` reconstructs a representative of each class. -/
def ReconstructionCorrect {α : Type u} {β : Type v}
    (π : α → β) (σ : β → α) : Prop :=
  ∀ q, π (σ q) = q

/-- Observables that are constant on operational fibres. -/
def Respects {α : Type u} {β : Type v} {γ : Type w}
    (π : α → β) (f : α → γ) : Prop :=
  ∀ x y, π x = π y → f x = f y

/-- Explicit iteration, independent of Mathlib `f^[n]`. -/
def iterate {α : Type _} (T : α → α) : Nat → α → α
  | 0,     x => x
  | n + 1, x => T (iterate T n x)

theorem iterate_zero {α : Type _} (T : α → α) (x : α) :
    iterate T 0 x = x :=
  rfl

theorem iterate_succ {α : Type _} (T : α → α) (n : Nat) (x : α) :
    iterate T (n + 1) x = T (iterate T n x) :=
  rfl

theorem iterate_one {α : Type _} (T : α → α) (x : α) :
    iterate T 1 x = T x :=
  rfl

/-! ## Equivalence of operational equality -/

theorem equivalent_refl {α : Type u} {β : Type v}
    (π : α → β) (x : α) : Equivalent π x x :=
  rfl

theorem equivalent_symm {α : Type u} {β : Type v}
    (π : α → β) {x y : α} :
    Equivalent π x y → Equivalent π y x :=
  Eq.symm

theorem equivalent_trans {α : Type u} {β : Type v}
    (π : α → β) {x y z : α} :
    Equivalent π x y → Equivalent π y z → Equivalent π x z :=
  Eq.trans

theorem equivalent_equivalence {α : Type u} {β : Type v} (π : α → β) :
    Equivalence (Equivalent π) :=
  ⟨equivalent_refl π,
   fun {_ _} h => equivalent_symm π h,
   fun {_ _ _} hxy hyz => equivalent_trans π hxy hyz⟩

/-! ## One-step descent ↔ recursive equivalence -/

theorem descends_implies_recursive {α : Type u} {β : Type v}
    (π : α → β) {T : α → α} {Tbar : β → β}
    (h : Descends π T Tbar) :
    ∀ n x, π (iterate T n x) = iterate Tbar n (π x) := by
  intro n
  induction n with
  | zero =>
      intro x
      rfl
  | succ n ih =>
      intro x
      calc
        π (iterate T (n + 1) x)
            = π (T (iterate T n x)) := rfl
        _   = Tbar (π (iterate T n x)) := h (iterate T n x)
        _   = Tbar (iterate Tbar n (π x)) := by rw [ih x]
        _   = iterate Tbar (n + 1) (π x) := rfl

theorem recursive_implies_descends {α : Type u} {β : Type v}
    (π : α → β) {T : α → α} {Tbar : β → β}
    (h : ∀ n x, π (iterate T n x) = iterate Tbar n (π x)) :
    Descends π T Tbar := by
  intro x
  have hx := h 1 x
  exact hx

/-- Core biconditional: one-step intertwining is equivalent to
    intertwining of every finite iterate. No cost premise. -/
theorem descends_iff_recursive {α : Type u} {β : Type v}
    (π : α → β) (T : α → α) (Tbar : β → β) :
    Descends π T Tbar ↔
      ∀ n x, π (iterate T n x) = iterate Tbar n (π x) :=
  ⟨descends_implies_recursive π,
   recursive_implies_descends π⟩

/-! ## Class preservation -/

theorem preservesClass_iff_descends_id {α : Type u} {β : Type v}
    (π : α → β) (T : α → α) :
    PreservesClass π T ↔ Descends π T id :=
  Iff.rfl

theorem descends_preserves_class {α : Type u} {β : Type v}
    (π : α → β) {T : α → α} {Tbar : β → β}
    (h : Descends π T Tbar) {x y : α}
    (hxy : Equivalent π x y) :
    Equivalent π (T x) (T y) := by
  unfold Equivalent at *
  calc
    π (T x) = Tbar (π x) := h x
    _       = Tbar (π y) := by rw [hxy]
    _       = π (T y)    := (h y).symm

theorem descends_implies_wellDefined {α : Type u} {β : Type v}
    (π : α → β) {T : α → α} {Tbar : β → β}
    (h : Descends π T Tbar) :
    WellDefined π T :=
  fun x y hxy => descends_preserves_class π h hxy

/-! ## Representative-induced quotient descent -/

/-- Quotient operator induced by a chosen section `σ`. -/
def induced {α : Type u} {β : Type v}
    (π : α → β) (T : α → α) (σ : β → α) : β → β :=
  fun q => π (T (σ q))

theorem induced_descends {α : Type u} {β : Type v}
    (π : α → β) (T : α → α) (σ : β → α)
    (hσ : ReconstructionCorrect π σ)
    (hT : WellDefined π T) :
    Descends π T (induced π T σ) := by
  intro x
  have hx : π (σ (π x)) = π x := hσ (π x)
  exact hT x (σ (π x)) hx.symm

/-! ## Quotient-operator uniqueness -/

theorem quotient_operator_unique {α : Type u} {β : Type v}
    (π : α → β) {T : α → α} {Tbar₁ Tbar₂ : β → β}
    (hπ : Function.Surjective π)
    (h₁ : Descends π T Tbar₁)
    (h₂ : Descends π T Tbar₂) :
    Tbar₁ = Tbar₂ := by
  funext q
  obtain ⟨x, hx⟩ := hπ q
  calc
    Tbar₁ q = Tbar₁ (π x) := by rw [hx]
    _       = π (T x)     := (h₁ x).symm
    _       = Tbar₂ (π x) := h₂ x
    _       = Tbar₂ q     := by rw [hx]

theorem induced_unique {α : Type u} {β : Type v}
    (π : α → β) {T : α → α} {Tbar : β → β} (σ : β → α)
    (hσ : ReconstructionCorrect π σ)
    (h : Descends π T Tbar) :
    Tbar = induced π T σ := by
  funext q
  calc
    Tbar q = Tbar (π (σ q)) := by rw [hσ q]
    _      = π (T (σ q))    := (h (σ q)).symm
    _      = induced π T σ q := rfl

/-! ## Observable factorization -/

def observableFactor {α : Type u} {β : Type v} {γ : Type w}
    (π : α → β) (f : α → γ) (σ : β → α) : β → γ :=
  fun q => f (σ q)

theorem observable_factors {α : Type u} {β : Type v} {γ : Type w}
    (π : α → β) (f : α → γ) (σ : β → α)
    (hσ : ReconstructionCorrect π σ)
    (hf : Respects π f) :
    ∀ x, f x = observableFactor π f σ (π x) := by
  intro x
  exact hf x (σ (π x)) (hσ (π x)).symm

theorem observable_factor_unique {α : Type u} {β : Type v} {γ : Type w}
    (π : α → β) {f : α → γ} {fbar₁ fbar₂ : β → γ}
    (hπ : Function.Surjective π)
    (h₁ : ∀ x, f x = fbar₁ (π x))
    (h₂ : ∀ x, f x = fbar₂ (π x)) :
    fbar₁ = fbar₂ := by
  funext q
  obtain ⟨x, hx⟩ := hπ q
  calc
    fbar₁ q = fbar₁ (π x) := by rw [hx]
    _       = f x         := (h₁ x).symm
    _       = fbar₂ (π x) := h₂ x
    _       = fbar₂ q     := by rw [hx]

/-! ## Reconstruction modulo equivalence -/

theorem reconstruction_is_section {α : Type u} {β : Type v}
    (π : α → β) (σ : β → α)
    (hσ : ReconstructionCorrect π σ) :
    π ∘ σ = id := by
  funext q
  exact hσ q

theorem reconstruction_modulo_equivalence {α : Type u} {β : Type v}
    (π : α → β) (σ : β → α)
    (hσ : ReconstructionCorrect π σ) :
    ∀ x, Equivalent π x (σ (π x)) := by
  intro x
  exact (hσ (π x)).symm

theorem conjugate_of_descent {α : Type u} {β : Type v}
    (π : α → β) (σ : β → α)
    (hσ : ReconstructionCorrect π σ)
    {T : α → α} {Tbar : β → β}
    (h : Descends π T Tbar) :
    π ∘ T ∘ σ = Tbar := by
  funext q
  calc
    (π ∘ T ∘ σ) q = π (T (σ q)) := rfl
    _             = Tbar (π (σ q)) := h (σ q)
    _             = Tbar q := by rw [hσ q]

/-! ## External realization cost (never a semantic hypothesis) -/

/-- Realization cost lives *outside* the operational calculus.
    It may annotate a physical or computational implementation,
    but it is not a premise of any semantic theorem below. -/
structure ExternalCost where
  realize : Nat → Nat

/-- A proposition is cost-independent when it does not quantify over cost. -/
def CostIndependent (P : Prop) : Prop := P

/-! ## Three positive literal instances -/

/-- Instance I1: identity projection intertwines successor with successor. -/
def π_id : Nat → Nat := id
def T_succ : Nat → Nat := Nat.succ

theorem instance_identity_successor :
    Descends π_id T_succ T_succ := by
  intro x
  rfl

theorem instance_identity_successor_recursive :
    ∀ n x, π_id (iterate T_succ n x) = iterate T_succ n (π_id x) :=
  (descends_iff_recursive π_id T_succ T_succ).mp instance_identity_successor

/-- Instance I2: terminal projection. Every hidden operator descends to `id`. -/
def π_unit (_ : Nat) : Unit := ()
def T_shift (n : Nat) : Nat := n + 7
def Tbar_unit : Unit → Unit := id

theorem instance_terminal_projection :
    Descends π_unit T_shift Tbar_unit := by
  intro x
  rfl

/-- Instance I3: first-component projection. Trailing coordinates are hidden. -/
def π_fst : Nat × Nat → Nat := Prod.fst
def T_trail : Nat × Nat → Nat × Nat := fun p => (p.1, p.2 + 1)
def Tbar_fst : Nat → Nat := id

theorem instance_first_component :
    Descends π_fst T_trail Tbar_fst := by
  intro p
  rfl

theorem instance_first_component_preserves_class :
    PreservesClass π_fst T_trail :=
  instance_first_component

/-! ## Three corresponding counterexamples -/

/-- Counterexample C1: identity projection does not send successor to a constant. -/
theorem counterexample_successor_not_constant :
    ¬ Descends (id : Nat → Nat) Nat.succ (fun _ => 0) := by
  intro h
  have hx := h 0
  exact (Nat.succ_ne_zero 0) hx

/-- Counterexample C2: a constant projection does not intertwine `id` with successor. -/
theorem counterexample_constant_not_successor :
    ¬ Descends (fun _ : Nat => (0 : Nat)) id Nat.succ := by
  intro h
  have hx := h 0
  exact (Nat.succ_ne_zero 0) hx.symm

/-- Counterexample C3: identity projection does not send identity to successor. -/
theorem counterexample_identity_not_successor :
    ¬ Descends (id : Nat → Nat) id Nat.succ := by
  intro h
  have hx := h 0
  exact (Nat.succ_ne_zero 0) hx.symm

/-! ## Packaged universal closure — no cost premise -/

/-- Semantic closure of operational equivalence, independent of realization cost. -/
theorem universal_cost_independent_operational_closure
    {α : Type u} {β : Type v} (π : α → β) :
    Equivalence (Equivalent π) ∧
    (∀ T : α → α, ∀ Tbar : β → β,
      Descends π T Tbar ↔
        ∀ n x, π (iterate T n x) = iterate Tbar n (π x)) ∧
    (∀ T : α → α, ∀ Tbar : β → β,
      Descends π T Tbar →
        ∀ x y, Equivalent π x y → Equivalent π (T x) (T y)) ∧
    (∀ T : α → α, ∀ σ : β → α,
      ReconstructionCorrect π σ →
      WellDefined π T →
      Descends π T (induced π T σ)) ∧
    (Function.Surjective π →
      ∀ T : α → α, ∀ Tbar₁ Tbar₂ : β → β,
        Descends π T Tbar₁ →
        Descends π T Tbar₂ →
        Tbar₁ = Tbar₂) ∧
    (∀ {γ : Type w} (f : α → γ) (σ : β → α),
      ReconstructionCorrect π σ →
      Respects π f →
      ∀ x, f x = observableFactor π f σ (π x)) ∧
    (∀ σ : β → α,
      ReconstructionCorrect π σ →
      (π ∘ σ = id) ∧ ∀ x, Equivalent π x (σ (π x))) ∧
    CostIndependent
      (Descends π_id T_succ T_succ ∧
       Descends π_unit T_shift Tbar_unit ∧
       Descends π_fst T_trail Tbar_fst) := by
  refine ⟨?equiv, ?rec, ?cls, ?ind, ?uniq, ?obs, ?recon, ?lit⟩
  · exact equivalent_equivalence π
  · intro T Tbar
    exact descends_iff_recursive π T Tbar
  · intro T Tbar h x y hxy
    exact descends_preserves_class π h hxy
  · intro T σ hσ hT
    exact induced_descends π T σ hσ hT
  · intro hπ T Tbar₁ Tbar₂ h₁ h₂
    exact quotient_operator_unique π hπ h₁ h₂
  · intro γ f σ hσ hf x
    exact observable_factors π f σ hσ hf x
  · intro σ hσ
    exact ⟨reconstruction_is_section π σ hσ,
           reconstruction_modulo_equivalence π σ hσ⟩
  · exact ⟨instance_identity_successor,
           instance_terminal_projection,
           instance_first_component⟩

/-- Literal witnesses packaged with their counterexamples.
    Status of the *logic* does not depend on `ExternalCost`. -/
theorem instances_and_counterexamples :
    Descends π_id T_succ T_succ ∧
    Descends π_unit T_shift Tbar_unit ∧
    Descends π_fst T_trail Tbar_fst ∧
    ¬ Descends (id : Nat → Nat) Nat.succ (fun _ => 0) ∧
    ¬ Descends (fun _ : Nat => (0 : Nat)) id Nat.succ ∧
    ¬ Descends (id : Nat → Nat) id Nat.succ :=
  ⟨instance_identity_successor,
   instance_terminal_projection,
   instance_first_component,
   counterexample_successor_not_constant,
   counterexample_constant_not_successor,
   counterexample_identity_not_successor⟩

end SIM2XR.UniversalCostless
