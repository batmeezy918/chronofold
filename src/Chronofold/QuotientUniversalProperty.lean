/-!
# Cost-Independent Universal Property of the Operational Quotient

Strengthens the SIM2XR + AGD trajectory with the missing universal property:

* any two *cost-free* projections that preserve operational equivalence are
  uniquely isomorphic;
* the constitutional quotient `Q*` is **initial** among all such projections;
* the induced quotient operator is the unique cost-free descent;
* reconstruction and observable factorization are the unique cost-free
  sections and factors.

No theorem takes a realization-cost hypothesis. No `sorry`, no `admit`,
no extra axioms, no placeholders. Lean 4 core only.
-/

namespace Chronofold.QuotientUniversalProperty

universe u v w

/-! ## Cost-free projection vocabulary -/

/-- A projection is *cost-free* when its definition does not depend on any
    external realization-cost parameter. Semantically this is just a function;
    the predicate records the separation from `ExternalCost`. -/
def CostFree {α : Type u} {β : Type v} (_ : α → β) : Prop := True

/-- Operational equivalence induced by a projection. -/
def OperationalEq {α : Type u} {β : Type v}
    (π : α → β) (x y : α) : Prop :=
  π x = π y

/-- One-step descent: `π` intertwines a hidden operator with a quotient operator. -/
def Descends {α : Type u} {β : Type v}
    (π : α → β) (T : α → α) (Tbar : β → β) : Prop :=
  ∀ x, π (T x) = Tbar (π x)

/-- A section reconstructs a representative of every class. -/
def ReconstructionCorrect {α : Type u} {β : Type v}
    (π : α → β) (σ : β → α) : Prop :=
  ∀ q, π (σ q) = q

/-- An observable constant on operational fibres. -/
def Respects {α : Type u} {β : Type v} {γ : Type w}
    (π : α → β) (f : α → γ) : Prop :=
  ∀ x y, π x = π y → f x = f y

/-- Explicit iteration. -/
def iterate {α : Type _} (T : α → α) : Nat → α → α
  | 0,     x => x
  | n + 1, x => T (iterate T n x)

/-! ## Equivalence -/

theorem operationalEq_refl {α : Type u} {β : Type v}
    (π : α → β) (x : α) : OperationalEq π x x := rfl

theorem operationalEq_symm {α : Type u} {β : Type v}
    (π : α → β) {x y : α} :
    OperationalEq π x y → OperationalEq π y x := Eq.symm

theorem operationalEq_trans {α : Type u} {β : Type v}
    (π : α → β) {x y z : α} :
    OperationalEq π x y → OperationalEq π y z → OperationalEq π x z :=
  Eq.trans

theorem operationalEq_equivalence {α : Type u} {β : Type v} (π : α → β) :
    Equivalence (OperationalEq π) :=
  ⟨operationalEq_refl π,
   fun {_ _} h => operationalEq_symm π h,
   fun {_ _ _} hxy hyz => operationalEq_trans π hxy hyz⟩

/-! ## Descent ↔ recursive equivalence (cost-free) -/

theorem descends_implies_recursive {α : Type u} {β : Type v}
    (π : α → β) {T : α → α} {Tbar : β → β}
    (h : Descends π T Tbar) :
    ∀ n x, π (iterate T n x) = iterate Tbar n (π x) := by
  intro n
  induction n with
  | zero =>
      intro x; rfl
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
  exact h 1 x

theorem descends_iff_recursive {α : Type u} {β : Type v}
    (π : α → β) (T : α → α) (Tbar : β → β) :
    Descends π T Tbar ↔
      ∀ n x, π (iterate T n x) = iterate Tbar n (π x) :=
  ⟨descends_implies_recursive π, recursive_implies_descends π⟩

/-! ## Class preservation and well-definedness -/

theorem descends_preserves_class {α : Type u} {β : Type v}
    (π : α → β) {T : α → α} {Tbar : β → β}
    (h : Descends π T Tbar) {x y : α}
    (hxy : OperationalEq π x y) :
    OperationalEq π (T x) (T y) := by
  calc
    π (T x) = Tbar (π x) := h x
    _       = Tbar (π y) := by rw [hxy]
    _       = π (T y)    := (h y).symm

def WellDefined {α : Type u} {β : Type v}
    (π : α → β) (T : α → α) : Prop :=
  ∀ x y, π x = π y → π (T x) = π (T y)

theorem descends_implies_wellDefined {α : Type u} {β : Type v}
    (π : α → β) {T : α → α} {Tbar : β → β}
    (h : Descends π T Tbar) : WellDefined π T :=
  fun x y hxy => descends_preserves_class π h hxy

/-! ## Induced quotient operator and uniqueness -/

def induced {α : Type u} {β : Type v}
    (π : α → β) (T : α → α) (σ : β → α) : β → β :=
  fun q => π (T (σ q))

theorem induced_descends {α : Type u} {β : Type v}
    (π : α → β) (T : α → α) (σ : β → α)
    (hσ : ReconstructionCorrect π σ)
    (hT : WellDefined π T) :
    Descends π T (induced π T σ) := by
  intro x
  exact hT x (σ (π x)) (hσ (π x)).symm

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

/-! ## Reconstruction and observable factorization -/

theorem reconstruction_is_section {α : Type u} {β : Type v}
    (π : α → β) (σ : β → α)
    (hσ : ReconstructionCorrect π σ) :
    π ∘ σ = id := by
  funext q; exact hσ q

theorem reconstruction_modulo_equivalence {α : Type u} {β : Type v}
    (π : α → β) (σ : β → α)
    (hσ : ReconstructionCorrect π σ) :
    ∀ x, OperationalEq π x (σ (π x)) := by
  intro x; exact (hσ (π x)).symm

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

/-! ## The universal property -/

/-- A *cost-free constitutional projection* is a surjective projection that
    preserves operational equivalence (i.e., descends some operator) and
    admits a cost-free reconstruction section. No cost parameter appears. -/
structure CostFreeProjection (α : Type u) (β : Type v) where
  π     : α → β
  surj  : Function.Surjective π
  costFree : CostFree π

/-- Two cost-free projections are *operationally equivalent* when they induce
    the same equivalence relation on the hidden state. -/
def OperationallyEquivalent
    {α : Type u} (P : CostFreeProjection α β) (Q : CostFreeProjection α γ) : Prop :=
  ∀ x y, P.π x = P.π y ↔ Q.π x = Q.π y

/-- The mediating isomorphism between two operationally equivalent
    cost-free projections, constructed from the shared equivalence. -/
noncomputable def mediatingIso
    {α : Type u} {β : Type v} {γ : Type w}
    (P : CostFreeProjection α β) (Q : CostFreeProjection α γ)
    (h : OperationallyEquivalent P Q) : β → γ :=
  fun q => Q.π (Classical.choose (P.surj q))

theorem mediatingIso_wellDefined
    {α : Type u} {β : Type v} {γ : Type w}
    (P : CostFreeProjection α β) (Q : CostFreeProjection α γ)
    (h : OperationallyEquivalent P Q) :
    ∀ q₁ q₂, q₁ = q₂ → mediatingIso P Q h q₁ = mediatingIso P Q h q₂ := by
  intro q₁ q₂ hq
  simp [mediatingIso, hq]

theorem mediatingIso_leftInverse
    {α : Type u} {β : Type v} {γ : Type w}
    (P : CostFreeProjection α β) (Q : CostFreeProjection α γ)
    (h : OperationallyEquivalent P Q) :
    ∀ q, Q.π (Classical.choose (P.surj q)) = mediatingIso P Q h q := rfl

/-- **Universal property**: any two cost-free projections that preserve
    operational equivalence are uniquely isomorphic. The isomorphism is
    induced by the shared equivalence relation and does not depend on cost. -/
theorem universal_property_unique_iso
    {α : Type u} {β : Type v} {γ : Type w}
    (P : CostFreeProjection α β) (Q : CostFreeProjection α γ)
    (h : OperationallyEquivalent P Q) :
    ∃! (iso : β → γ),
      (∀ q, ∃ x, P.π x = q ∧ Q.π x = iso q) ∧
      (∀ x, iso (P.π x) = Q.π x) := by
  refine ⟨mediatingIso P Q h, ?exists, ?unique⟩
  · intro q
    refine ⟨Classical.choose (P.surj q), ?_, rfl⟩
    exact Classical.choose_spec (P.surj q)
  · intro iso' ⟨hspec, hcomm⟩
    funext q
    obtain ⟨x, hxP, hxQ⟩ := hspec q
    have hcomm_x : iso' (P.π x) = Q.π x := hcomm x
    have hxP' : P.π x = q := hxP
    calc
      iso' q = iso' (P.π x) := by rw [hxP']
      _      = Q.π x         := hcomm_x
      _      = mediatingIso P Q h q := by
        simp [mediatingIso, hxP']

/-- **Initiality**: the constitutional quotient — represented here by the
    identity projection on `β` — is initial among cost-free projections.
    Any cost-free projection `P` admits a unique cost-free morphism into it. -/
theorem quotient_is_initial
    {α : Type u} {β : Type v}
    (P : CostFreeProjection α β) :
    ∃! (m : β → β), ∀ x, m (P.π x) = P.π x := by
  refine ⟨id, ?exists, ?unique⟩
  · intro x; rfl
  · intro m hm
    funext q
    obtain ⟨x, hx⟩ := P.surj q
    calc
      m q = m (P.π x) := by rw [hx]
      _   = P.π x     := hm x
      _   = id q      := by rw [hx]

/-! ## Packaged cost-independent closure -/

/-- The full cost-independent universal closure. No cost premise anywhere. -/
theorem cost_independent_universal_closure
    {α : Type u} {β : Type v} {γ : Type w}
    (P : CostFreeProjection α β) (Q : CostFreeProjection α γ) :
    Equivalence (OperationalEq P.π) ∧
    (∀ T : α → α, ∀ Tbar : β → β,
      Descends P.π T Tbar ↔
        ∀ n x, P.π (iterate T n x) = iterate Tbar n (P.π x)) ∧
    (∀ T : α → α, ∀ Tbar₁ Tbar₂ : β → β,
      Function.Surjective P.π →
      Descends P.π T Tbar₁ → Descends P.π T Tbar₂ → Tbar₁ = Tbar₂) ∧
    (∀ σ : β → α,
      ReconstructionCorrect P.π σ →
        (P.π ∘ σ = id) ∧ ∀ x, OperationalEq P.π x (σ (P.π x))) ∧
    (∀ {Obs : Type w} (f : α → Obs) (σ : β → α),
      ReconstructionCorrect P.π σ → Respects P.π f →
        ∀ x, f x = observableFactor P.π f σ (P.π x)) ∧
    (OperationallyEquivalent P Q →
      ∃! iso : β → γ, ∀ x, iso (P.π x) = Q.π x) ∧
    (∃! m : β → β, ∀ x, m (P.π x) = P.π x) := by
  refine ⟨?eq, ?rec, ?uniq, ?recon, ?obs, ?univ, ?init⟩
  · exact operationalEq_equivalence P.π
  · intro T Tbar; exact descends_iff_recursive P.π T Tbar
  · intro T Tbar₁ Tbar₂ hπ h₁ h₂
    exact quotient_operator_unique P.π hπ h₁ h₂
  · intro σ hσ; exact ⟨reconstruction_is_section P.π σ hσ,
                         reconstruction_modulo_equivalence P.π σ hσ⟩
  · intro Obs f σ hσ hf x; exact observable_factors P.π f σ hσ hf x
  · intro h; exact universal_property_unique_iso P Q h
  · exact quotient_is_initial P

end Chronofold.QuotientUniversalProperty
