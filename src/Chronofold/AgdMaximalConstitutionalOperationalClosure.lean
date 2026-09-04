import Chronofold.MasterBidirectionalOperationalClosure
import Chronofold.AgdInvariantSafety

/-!
# Maximal Constitutional Operational Closure

Abstract constitutional calculus for a projection `π : H → Q`, together
with a faithful instantiation on the already-verified AGD kernel
(`Omega`, `Covariant`, `QStar`, `TBar`, `opIterate`).

Logical repairs relative to the thin skeleton:

* Admissibility is *not* equivalent to mere existence of a descent.
  Descent is equivalent to fibre-well-definedness. Admissibility is
  descent along the identity on `Q`.
* Uniqueness of the induced operator and of an observable factor
  requires surjectivity of `π` (always true for `pi` on `QStar`).
* Safety preservation is not free: it requires `CriticalFactors`,
  the exact relationship between a critical predicate and `π`.
* Iteration uses an explicit recursor rather than Mathlib `f^[n]`.

No vacuous markers. No placeholder predicates. Every proof is kernel-checked.
Lean 4 core only.
-/

universe u v w

namespace Chronofold.MaximalConstitutional

variable {H : Type u} {Q : Type v} {Obs : Type w}

/-! ## Primitive constitution -/

/-- Operational equivalence is equality in the constitutional quotient. -/
def OperationalEq (π : H → Q) (x y : H) : Prop :=
  π x = π y

/-- A transition descends iff its result depends only on the quotient class. -/
def Descends (π : H → Q) (T : H → H) (Tbar : Q → Q) : Prop :=
  ∀ x, π (T x) = Tbar (π x)

/-- Constitution-preserving transformation: every class is a fixed class. -/
def Admissible (π : H → Q) (T : H → H) : Prop :=
  ∀ x, π (T x) = π x

/-- Fibre well-definedness of a hidden-state operator. -/
def WellDefined (π : H → Q) (T : H → H) : Prop :=
  ∀ x y : H, π x = π y → π (T x) = π (T y)

/-- Explicit iteration, independent of Mathlib. -/
def iterate {α : Type _} (T : α → α) : Nat → α → α
  | 0,     x => x
  | n + 1, x => T (iterate T n x)

theorem iterate_zero {α : Type _} (T : α → α) (x : α) :
    iterate T 0 x = x :=
  rfl

theorem iterate_succ {α : Type _} (T : α → α) (n : Nat) (x : α) :
    iterate T (n + 1) x = T (iterate T n x) :=
  rfl

/-! ## 0. Operational equivalence is an equivalence relation -/

theorem operationalEq_refl (π : H → Q) (x : H) :
    OperationalEq π x x :=
  rfl

theorem operationalEq_symm (π : H → Q) {x y : H} :
    OperationalEq π x y → OperationalEq π y x :=
  Eq.symm

theorem operationalEq_trans (π : H → Q) {x y z : H} :
    OperationalEq π x y → OperationalEq π y z → OperationalEq π x z :=
  Eq.trans

theorem operationalEq_equivalence (π : H → Q) :
    Equivalence (OperationalEq π) :=
  ⟨operationalEq_refl π,
   fun {_ _} h => operationalEq_symm π h,
   fun {_ _ _} hxy hyz => operationalEq_trans π hxy hyz⟩

/-! ## 1. Bidirectional constitution / admissibility -/

/-- Definitional biconditional requested by the skeleton, kept explicit. -/
theorem admissible_iff_class_preserved (π : H → Q) (T : H → H) :
    Admissible π T ↔ ∀ x, π (T x) = π x :=
  Iff.rfl

/-- Non-definitional elevation: admissibility is operational self-equivalence. -/
theorem admissible_iff_operational_fixed (π : H → Q) (T : H → H) :
    Admissible π T ↔ ∀ x, OperationalEq π (T x) x :=
  Iff.rfl

/-- Admissibility is exactly descent of the identity on the quotient. -/
theorem admissible_iff_descends_id (π : H → Q) (T : H → H) :
    Admissible π T ↔ Descends π T id :=
  Iff.rfl

/-! ## 2. Quotient execution -/

theorem iterate_id {α : Type _} (n : Nat) (x : α) :
    iterate (id : α → α) n x = x := by
  induction n with
  | zero => rfl
  | succ n ih =>
      simp [iterate, id, ih]

theorem descends_implies_wellDefined
    (π : H → Q) {T : H → H} {Tbar : Q → Q}
    (h : Descends π T Tbar) :
    WellDefined π T := by
  intro x y hxy
  calc
    π (T x) = Tbar (π x) := h x
    _       = Tbar (π y) := by rw [hxy]
    _       = π (T y)    := (h y).symm

/-- Existence of a descent, on the image of a surjective projection. -/
noncomputable def induced
    (π : H → Q) (T : H → H) (hπ : Function.Surjective π) : Q → Q :=
  fun q => π (T (Classical.choose (hπ q)))

theorem induced_descends
    (π : H → Q) (T : H → H)
    (hπ : Function.Surjective π) (hT : WellDefined π T) :
    Descends π T (induced π T hπ) := by
  intro x
  have hx : π (Classical.choose (hπ (π x))) = π x :=
    Classical.choose_spec (hπ (π x))
  have hEq : π (T x) = π (T (Classical.choose (hπ (π x)))) :=
    hT x (Classical.choose (hπ (π x))) hx.symm
  exact hEq

theorem wellDefined_iff_exists_descent
    (π : H → Q) (T : H → H) (hπ : Function.Surjective π) :
    WellDefined π T ↔ ∃ Tbar : Q → Q, Descends π T Tbar := by
  constructor
  · intro hT
    exact ⟨induced π T hπ, induced_descends π T hπ hT⟩
  · intro ⟨Tbar, h⟩
    exact descends_implies_wellDefined π h

/-- Correct replacement for the skeleton's false
    `Admissible ↔ ∃ Tbar, Descends`. -/
theorem admissible_iff_identity_descent
    (π : H → Q) (T : H → H) :
    Admissible π T ↔ Descends π T id :=
  admissible_iff_descends_id π T

theorem admissible_implies_exists_descent
    (π : H → Q) (T : H → H) (hT : Admissible π T) :
    ∃ Tbar : Q → Q, Descends π T Tbar :=
  ⟨id, hT⟩

theorem quotient_operator_unique
    (π : H → Q) {T : H → H} {Tbar₁ Tbar₂ : Q → Q}
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

/-! ## 3. Iterative closure -/

theorem quotient_iterate
    (π : H → Q) {T : H → H} {Tbar : Q → Q}
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

theorem admissible_iterate
    (π : H → Q) {T : H → H}
    (hT : Admissible π T) :
    ∀ n, Admissible π (iterate T n) := by
  intro n x
  have h := quotient_iterate π (Tbar := id) hT n x
  rw [iterate_id] at h
  exact h

/-! ## 4. Compositional closure -/

theorem descends_compose
    (π : H → Q)
    {T₁ T₂ : H → H} {B₁ B₂ : Q → Q}
    (h₁ : Descends π T₁ B₁)
    (h₂ : Descends π T₂ B₂) :
    Descends π (T₁ ∘ T₂) (B₁ ∘ B₂) := by
  intro x
  calc
    π ((T₁ ∘ T₂) x) = π (T₁ (T₂ x)) := rfl
    _               = B₁ (π (T₂ x)) := h₁ (T₂ x)
    _               = B₁ (B₂ (π x)) := by rw [h₂ x]
    _               = (B₁ ∘ B₂) (π x) := rfl

theorem wellDefined_compose
    (π : H → Q) {T₁ T₂ : H → H}
    (h₁ : WellDefined π T₁)
    (h₂ : WellDefined π T₂) :
    WellDefined π (T₁ ∘ T₂) := by
  intro x y hxy
  exact h₁ (T₂ x) (T₂ y) (h₂ x y hxy)

theorem admissible_compose
    (π : H → Q) {T₁ T₂ : H → H}
    (h₁ : Admissible π T₁)
    (h₂ : Admissible π T₂) :
    Admissible π (T₁ ∘ T₂) := by
  intro x
  calc
    π ((T₁ ∘ T₂) x) = π (T₁ (T₂ x)) := rfl
    _               = π (T₂ x)      := h₁ (T₂ x)
    _               = π x           := h₂ x

theorem quotient_identity (π : H → Q) :
    Descends π (id : H → H) (id : Q → Q) := by
  intro x
  rfl

theorem admissible_id (π : H → Q) :
    Admissible π (id : H → H) :=
  quotient_identity π

theorem quotient_operator_associative
    (A B C : Q → Q) :
    (A ∘ B) ∘ C = A ∘ (B ∘ C) := by
  funext q
  rfl

/-- Descent is a monoid homomorphism from hidden operators to `Q → Q`. -/
theorem descent_monoid_hom
    (π : H → Q)
    {T₁ T₂ : H → H} {B₁ B₂ : Q → Q}
    (h₁ : Descends π T₁ B₁)
    (h₂ : Descends π T₂ B₂) :
    Descends π (id : H → H) (id : Q → Q) ∧
      Descends π (T₁ ∘ T₂) (B₁ ∘ B₂) :=
  ⟨quotient_identity π, descends_compose π h₁ h₂⟩

/-! ## 5. Reconstruction -/

def ReconstructionCorrect (π : H → Q) (σ : Q → H) : Prop :=
  ∀ q, π (σ q) = q

theorem reconstruction_roundtrip
    (π : H → Q) (σ : Q → H)
    (hσ : ReconstructionCorrect π σ) :
    ∀ q, π (σ q) = q :=
  hσ

theorem operational_roundtrip
    (π : H → Q) (σ : Q → H)
    (hσ : ReconstructionCorrect π σ) :
    ∀ x, OperationalEq π x (σ (π x)) := by
  intro x
  exact (hσ (π x)).symm

theorem reconstruction_is_section
    (π : H → Q) (σ : Q → H)
    (hσ : ReconstructionCorrect π σ) :
    π ∘ σ = id := by
  funext q
  exact hσ q

theorem conjugate_of_descent
    (π : H → Q) (σ : Q → H)
    (hσ : ReconstructionCorrect π σ)
    {T : H → H} {Tbar : Q → Q}
    (h : Descends π T Tbar) :
    π ∘ T ∘ σ = Tbar := by
  funext q
  calc
    (π ∘ T ∘ σ) q = π (T (σ q)) := rfl
    _             = Tbar (π (σ q)) := h (σ q)
    _             = Tbar q := by rw [hσ q]

theorem reconstructed_drive_operationally_equals
    (π : H → Q) (σ : Q → H)
    (hσ : ReconstructionCorrect π σ)
    {T : H → H} {Tbar : Q → Q}
    (h : Descends π T Tbar) :
    ∀ x, OperationalEq π (T x) ((σ ∘ Tbar ∘ π) x) := by
  intro x
  have hx : π (T x) = Tbar (π x) := h x
  have hσT : π (σ (Tbar (π x))) = Tbar (π x) := hσ (Tbar (π x))
  exact hx.trans hσT.symm

/-! ## 6. Observable factorization -/

def RespectsConstitution (π : H → Q) (f : H → Obs) : Prop :=
  ∀ x y : H, π x = π y → f x = f y

noncomputable def observableFactor
    (π : H → Q) (f : H → Obs)
    (hπ : Function.Surjective π) : Q → Obs :=
  fun q => f (Classical.choose (hπ q))

theorem observable_factors
    (π : H → Q) (f : H → Obs)
    (hf : RespectsConstitution π f)
    (hπ : Function.Surjective π) :
    ∃ fbar : Q → Obs, ∀ x, f x = fbar (π x) := by
  refine ⟨observableFactor π f hπ, ?_⟩
  intro x
  have hx : π (Classical.choose (hπ (π x))) = π x :=
    Classical.choose_spec (hπ (π x))
  exact (hf (Classical.choose (hπ (π x))) x hx).symm

theorem observable_factor_unique
    (π : H → Q) {f : H → Obs}
    {fbar₁ fbar₂ : Q → Obs}
    (h₁ : ∀ x, f x = fbar₁ (π x))
    (h₂ : ∀ x, f x = fbar₂ (π x))
    (hπ : Function.Surjective π) :
    fbar₁ = fbar₂ := by
  funext q
  obtain ⟨x, hx⟩ := hπ q
  calc
    fbar₁ q = fbar₁ (π x) := by rw [hx]
    _       = f x         := (h₁ x).symm
    _       = fbar₂ (π x) := h₂ x
    _       = fbar₂ q     := by rw [hx]

theorem admissible_preserves_respecting_observable
    (π : H → Q) (f : H → Obs)
    (hf : RespectsConstitution π f)
    {T : H → H} (hT : Admissible π T) :
    ∀ x, f (T x) = f x := by
  intro x
  exact hf (T x) x (hT x)

/-! ## 7. Safety completeness -/

def Safe (critical : H → Prop) (T : H → H) : Prop :=
  ∀ x, critical x → critical (T x)

/-- The critical predicate is constant on constitutional fibres. -/
def CriticalFactors (π : H → Q) (critical : H → Prop) : Prop :=
  ∀ x y : H, π x = π y → (critical x ↔ critical y)

theorem admissible_preserves_safe
    (π : H → Q) {T : H → H} {critical : H → Prop}
    (hT : Admissible π T)
    (hC : CriticalFactors π critical) :
    Safe critical T := by
  intro x hx
  exact (hC x (T x) (hT x).symm).mp hx

theorem admissible_reflects_safe
    (π : H → Q) {T : H → H} {critical : H → Prop}
    (hT : Admissible π T)
    (hC : CriticalFactors π critical) :
    ∀ x, critical (T x) → critical x := by
  intro x hx
  exact (hC x (T x) (hT x).symm).mpr hx

theorem safe_compose
    {critical : H → Prop} {T₁ T₂ : H → H}
    (h₁ : Safe critical T₁)
    (h₂ : Safe critical T₂) :
    Safe critical (T₁ ∘ T₂) := by
  intro x hx
  exact h₁ (T₂ x) (h₂ x hx)

theorem safe_iterate
    {critical : H → Prop} {T : H → H}
    (hT : Safe critical T) :
    ∀ n, Safe critical (iterate T n) := by
  intro n
  induction n with
  | zero =>
      intro x hx
      simpa [iterate] using hx
  | succ n ih =>
      intro x hx
      exact hT (iterate T n x) (ih x hx)

theorem descends_preserves_safe
    (π : H → Q) {T : H → H} {Tbar : Q → Q} {critical : H → Prop}
    (h : Descends π T Tbar)
    (hC : CriticalFactors π critical)
    (hBar : ∀ q, (∃ x, π x = q ∧ critical x) →
      ∃ y, π y = Tbar q ∧ critical y) :
    Safe critical T := by
  intro x hx
  have : ∃ y, π y = Tbar (π x) ∧ critical y :=
    hBar (π x) ⟨x, rfl, hx⟩
  rcases this with ⟨y, hyπ, hyc⟩
  have : π (T x) = π y := (h x).trans hyπ.symm
  exact (hC (T x) y this).mpr hyc

/-! ## Packaged conjuncts (each a real proposition) -/

def OperationalEquivalence (π : H → Q) : Prop :=
  Equivalence (OperationalEq π)

def BidirectionalAdmissibility (π : H → Q) : Prop :=
  ∀ T : H → H,
    Admissible π T ↔ Descends π T id ∧ ∀ x, OperationalEq π (T x) x

def QuotientExecution (π : H → Q) : Prop :=
  Function.Surjective π →
    ∀ T : H → H,
      WellDefined π T ↔ ∃ Tbar : Q → Q, Descends π T Tbar

def IterativeClosure (π : H → Q) : Prop :=
  ∀ T : H → H, ∀ Tbar : Q → Q,
    Descends π T Tbar →
      ∀ n x, π (iterate T n x) = iterate Tbar n (π x)

def Reconstruction (π : H → Q) : Prop :=
  ∀ σ : Q → H,
    ReconstructionCorrect π σ →
      (π ∘ σ = id) ∧ ∀ x, OperationalEq π x (σ (π x))

def ObservableFactorization (π : H → Q) : Prop :=
  Function.Surjective π →
    ∀ {Obs' : Type w} (f : H → Obs'),
      RespectsConstitution π f →
        (∃ fbar : Q → Obs', ∀ x, f x = fbar (π x)) ∧
        (∀ fbar₁ fbar₂ : Q → Obs',
          (∀ x, f x = fbar₁ (π x)) →
          (∀ x, f x = fbar₂ (π x)) →
          fbar₁ = fbar₂)

def CompositionClosure (π : H → Q) : Prop :=
  Descends π (id : H → H) (id : Q → Q) ∧
    ∀ {T₁ T₂ : H → H} {B₁ B₂ : Q → Q},
      Descends π T₁ B₁ →
      Descends π T₂ B₂ →
      Descends π (T₁ ∘ T₂) (B₁ ∘ B₂)

def SafetyPreservation (π : H → Q) : Prop :=
  ∀ T : H → H, ∀ critical : H → Prop,
    Admissible π T →
    CriticalFactors π critical →
    Safe critical T ∧
      (∀ n, Safe critical (iterate T n))

/-! ## Maximal conjunction -/

theorem operationalEquivalence_holds (π : H → Q) :
    OperationalEquivalence π :=
  operationalEq_equivalence π

theorem bidirectionalAdmissibility_holds (π : H → Q) :
    BidirectionalAdmissibility π := by
  intro T
  constructor
  · intro hT
    exact ⟨hT, hT⟩
  · intro ⟨hId, _⟩
    exact hId

theorem quotientExecution_holds (π : H → Q) :
    QuotientExecution π := by
  intro hπ T
  exact wellDefined_iff_exists_descent π T hπ

theorem iterativeClosure_holds (π : H → Q) :
    IterativeClosure π := by
  intro T Tbar h
  exact quotient_iterate π h

theorem reconstruction_holds (π : H → Q) :
    Reconstruction π := by
  intro σ hσ
  exact ⟨reconstruction_is_section π σ hσ, operational_roundtrip π σ hσ⟩

theorem observableFactorization_holds (π : H → Q) :
    ObservableFactorization π := by
  intro hπ Obs' f hf
  constructor
  · exact observable_factors (Obs := Obs') π f hf hπ
  · intro fbar₁ fbar₂ h₁ h₂
    exact observable_factor_unique (Obs := Obs') π h₁ h₂ hπ

theorem compositionClosure_holds (π : H → Q) :
    CompositionClosure π :=
  ⟨quotient_identity π, fun {_ _ _ _} h₁ h₂ => descends_compose π h₁ h₂⟩

theorem safetyPreservation_holds (π : H → Q) :
    SafetyPreservation π := by
  intro T critical hT hC
  refine ⟨admissible_preserves_safe π hT hC, ?_⟩
  exact safe_iterate (admissible_preserves_safe π hT hC)

/-- Kernel-checked maximal constitutional operational closure.
    Every conjunct expands to a real proposition proved above. -/
theorem maximal_constitutional_operational_closure
    (π : H → Q) :
    OperationalEquivalence π ∧
    BidirectionalAdmissibility π ∧
    QuotientExecution π ∧
    IterativeClosure π ∧
    Reconstruction π ∧
    ObservableFactorization π ∧
    CompositionClosure π ∧
    SafetyPreservation π :=
  ⟨operationalEquivalence_holds π,
   bidirectionalAdmissibility_holds π,
   quotientExecution_holds π,
   iterativeClosure_holds π,
   reconstruction_holds π,
   observableFactorization_holds π,
   compositionClosure_holds π,
   safetyPreservation_holds π⟩

end Chronofold.MaximalConstitutional

/-! ## Faithful AGD instantiation of the abstract closure -/

namespace Chronofold.AGD

open Chronofold.MaximalConstitutional

universe u_agd v_agd

theorem agd_pi_surjective
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α) :
    Function.Surjective (pi α Ω C) :=
  fun q => exists_reconstruct α Ω C q

theorem agd_operationalEq_iff
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α)
    (s₁ s₂ : State α) :
    OperationalEq (pi α Ω C) s₁ s₂ ↔ interchangeable α Ω C s₁ s₂ :=
  Iff.rfl

theorem agd_admissible_iff_abstract
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) :
    Admissible α Ω C T ↔
      MaximalConstitutional.Admissible (pi α Ω C) T := by
  constructor
  · intro hT s
    exact Quotient.sound ⟨(hT s).1, (hT s).2⟩
  · intro hT s
    exact Quotient.exact (hT s)

theorem agd_TBar_descends
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T) :
    Descends (pi α Ω C) T (TBar α Ω C T hT) := by
  intro s
  exact (TBar_sound α Ω C T hT s).symm

theorem agd_TBar_unique
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T)
    (G : QStar α Ω C → QStar α Ω C)
    (hG : Descends (pi α Ω C) T G) :
    G = TBar α Ω C T hT :=
  quotient_operator_unique (pi α Ω C)
    (agd_pi_surjective α Ω C) hG (agd_TBar_descends α Ω C T hT)

theorem agd_iterate_matches_opIterate
    (α : Type u_agd) (T : Operator α) :
    ∀ n s, iterate T n s = opIterate α T n s := by
  intro n
  induction n with
  | zero =>
      intro s
      rfl
  | succ n ih =>
      intro s
      simp [iterate, opIterate, ih]

theorem agd_quotient_iterate
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T) :
    ∀ n s,
      pi α Ω C (opIterate α T n s) =
        iterate (TBar α Ω C T hT) n (pi α Ω C s) := by
  intro n s
  have hDesc : Descends (pi α Ω C) T (TBar α Ω C T hT) :=
    agd_TBar_descends α Ω C T hT
  have h := quotient_iterate (pi α Ω C) hDesc n s
  rw [agd_iterate_matches_opIterate α T n s] at h
  exact h

noncomputable def agdSection
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α) :
    QStar α Ω C → State α :=
  fun q => Classical.choose (exists_reconstruct α Ω C q)

theorem agd_reconstruction_correct
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α) :
    ReconstructionCorrect (pi α Ω C) (agdSection α Ω C) := by
  intro q
  exact Classical.choose_spec (exists_reconstruct α Ω C q)

/-- Constitutional observables `Ω` and `C` factor through `pi`. -/
theorem agd_constitution_respects_omega
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α) :
    RespectsConstitution (pi α Ω C) Ω := by
  intro s₁ s₂ h
  exact (Quotient.exact h).1

theorem agd_constitution_respects_C
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α) :
    RespectsConstitution (pi α Ω C) C := by
  intro s₁ s₂ h
  exact (Quotient.exact h).2

theorem agd_critical_of_omega
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α) (k : Nat) :
    CriticalFactors (pi α Ω C) (fun s => Ω s = k) := by
  intro s₁ s₂ h
  have hΩ : Ω s₁ = Ω s₂ := (Quotient.exact h).1
  constructor
  · intro hk
    exact hΩ.symm.trans hk
  · intro hk
    exact hΩ.trans hk

theorem agd_admissible_preserves_omega_level
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T) (k : Nat) :
    Safe (fun s => Ω s = k) T := by
  have hAbs : MaximalConstitutional.Admissible (pi α Ω C) T :=
    (agd_admissible_iff_abstract α Ω C T).mp hT
  exact admissible_preserves_safe (pi α Ω C) hAbs
    (agd_critical_of_omega α Ω C k)

/-- Instantiation of the maximal conjunction on the verified AGD kernel. -/
theorem agd_maximal_constitutional_operational_closure
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α) :
    OperationalEquivalence (pi α Ω C) ∧
    BidirectionalAdmissibility (pi α Ω C) ∧
    QuotientExecution (pi α Ω C) ∧
    IterativeClosure (pi α Ω C) ∧
    Reconstruction (pi α Ω C) ∧
    ObservableFactorization (pi α Ω C) ∧
    CompositionClosure (pi α Ω C) ∧
    SafetyPreservation (pi α Ω C) ∧
    (∀ T : Operator α,
      Admissible α Ω C T ↔
        MaximalConstitutional.Admissible (pi α Ω C) T) ∧
    (∀ T : Operator α, ∀ hT : Admissible α Ω C T,
      Descends (pi α Ω C) T (TBar α Ω C T hT)) ∧
    ReconstructionCorrect (pi α Ω C) (agdSection α Ω C) ∧
    invariantSafe α Ω C [Ω, C] := by
  refine ⟨?eq, ?bi, ?qe, ?it, ?re, ?ob, ?co, ?sa, ?iff, ?desc, ?sec, ?safe⟩
  · exact operationalEquivalence_holds (pi α Ω C)
  · exact bidirectionalAdmissibility_holds (pi α Ω C)
  · exact quotientExecution_holds (pi α Ω C)
  · exact iterativeClosure_holds (pi α Ω C)
  · exact reconstruction_holds (pi α Ω C)
  · exact observableFactorization_holds (pi α Ω C)
  · exact compositionClosure_holds (pi α Ω C)
  · exact safetyPreservation_holds (pi α Ω C)
  · intro T
    exact agd_admissible_iff_abstract α Ω C T
  · intro T hT
    exact agd_TBar_descends α Ω C T hT
  · exact agd_reconstruction_correct α Ω C
  · exact invariantSafe_omega_and_C α Ω C

/-- Strengthening of the existing master bidirectional package:
    every abstract conjunct holds on `pi`, and the master
    bidirectionality / TBar / iterate / reconstruction / universal
    / safety witnesses remain available. -/
theorem maximal_constitutional_operational_closure
    (α : Type u_agd) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) :
    OperationalEquivalence (pi α Ω C) ∧
    BidirectionalAdmissibility (pi α Ω C) ∧
    QuotientExecution (pi α Ω C) ∧
    IterativeClosure (pi α Ω C) ∧
    Reconstruction (pi α Ω C) ∧
    ObservableFactorization (pi α Ω C) ∧
    CompositionClosure (pi α Ω C) ∧
    SafetyPreservation (pi α Ω C) ∧
    ((∀ s, pi α Ω C (T s) = pi α Ω C s) ↔ Admissible α Ω C T) ∧
    (∀ hT : Admissible α Ω C T,
      ∀ s, TBar α Ω C T hT (pi α Ω C s) = pi α Ω C (T s)) ∧
    (∀ hT : Admissible α Ω C T,
      ∀ n s,
        TBar α Ω C (opIterate α T n)
          (admissible_iterate α Ω C T hT n)
          (pi α Ω C s) =
        pi α Ω C (opIterate α T n s)) ∧
    (∀ q : QStar α Ω C, ∃ s : State α, pi α Ω C s = q) ∧
    invariantSafe α Ω C [Ω, C] := by
  refine ⟨?eq, ?bi, ?qe, ?it, ?re, ?ob, ?co, ?sa, ?iff, ?sound, ?iter, ?recon, ?safe⟩
  · exact operationalEquivalence_holds (pi α Ω C)
  · exact bidirectionalAdmissibility_holds (pi α Ω C)
  · exact quotientExecution_holds (pi α Ω C)
  · exact iterativeClosure_holds (pi α Ω C)
  · exact reconstruction_holds (pi α Ω C)
  · exact observableFactorization_holds (pi α Ω C)
  · exact compositionClosure_holds (pi α Ω C)
  · exact safetyPreservation_holds (pi α Ω C)
  · exact admissible_iff_class_eq α Ω C T
  · intro hT s
    exact TBar_sound α Ω C T hT s
  · intro hT n s
    exact TBar_iterate_sound α Ω C T hT n s
  · intro q
    exact exists_reconstruct α Ω C q
  · exact invariantSafe_omega_and_C α Ω C

end Chronofold.AGD
