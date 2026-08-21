import Mathlib

set_option linter.unusedVariables false

open CategoryTheory

/- ===== The four locked axioms ===== -/
structure ConstitutionalSystem (S I : Type) where
  Ω        : S → I
  A        : S → S → Prop          -- axiom 2: admissible transitions
  nonempty : Nonempty S            -- axiom 1
  preserves : ∀ {s t}, A s t → Ω s = Ω t   -- axiom 4

variable {S I : Type} (C : ConstitutionalSystem S I)

/- ===== Theorem I: invariant equivalence is an equivalence relation ===== -/
def invRel (s t : S) : Prop := C.Ω s = C.Ω t

instance instSetoid (C : ConstitutionalSystem S I) : Setoid S where
  r     := invRel C
  iseqv := ⟨fun _ => rfl, fun h => h.symm, fun h1 h2 => h1.trans h2⟩

/- ===== Theorem II: canonical quotient + projection ===== -/
def Quot_ (C : ConstitutionalSystem S I) : Type := Quotient (instSetoid C)
def π (C : ConstitutionalSystem S I) (s : S) : Quot_ C := Quotient.mk (instSetoid C) s

/- ===== THEOREM P (PIVOTAL), BIDIRECTIONAL ===== -/
theorem pivotal (s t : S) : π C s = π C t ↔ C.Ω s = C.Ω t := by
  have h_sound : C.Ω s = C.Ω t → π C s = π C t := by
    intro h
    exact @Quotient.sound S (instSetoid C) s t h
  have h_exact : π C s = π C t → C.Ω s = C.Ω t := by
    intro h
    exact @Quotient.exact S (instSetoid C) s t h
  exact ⟨h_exact, h_sound⟩

/- ===== Theorem IV: identity preservation ===== -/
theorem identity_preservation {s t : S} (h : C.A s t) : π C s = π C t := by
  exact @Quotient.sound S (instSetoid C) s t (C.preserves h)

/- ===== Theorem III: fiber decomposition (statement) ===== -/
def Fiber (C : ConstitutionalSystem S I) (q : Quot_ C) : Set S := {s | π C s = q}
-- S = ⨆ (disjoint union) of fibers follows from Quotient.inductionOn

/- ===== Theorem V: path preservation (single step shown; iterate by induction) ===== -/
-- a path is a List of steps; preservation is `List.rec` on identity_preservation.
def ConstitutionalChain : S → List S → S → Prop
  | s, [], t => s = t
  | s, x :: xs, t => C.A s x ∧ ConstitutionalChain x xs t

theorem path_preservation {s t : S} (xs : List S) (h : ConstitutionalChain C s xs t) : π C s = π C t := by
  induction xs generalizing s with
  | nil =>
    dsimp [ConstitutionalChain] at h
    rw [h]
  | cons x xs ih =>
    dsimp [ConstitutionalChain] at h
    have h_step : π C s = π C x := identity_preservation C h.1
    have h_rest : π C x = π C t := ih h.2
    exact h_step.trans h_rest

/- ===== THE UNIVERSAL PROJECTION THEOREM ===== -/

-- Step 1: Admissible path represented as a typed inductive path from s to t
inductive AdmissiblePath : S → S → Type where
  | nil : ∀ s, AdmissiblePath s s
  | cons : ∀ {s t u}, C.A s t → AdmissiblePath t u → AdmissiblePath s u

-- Path concatenation
def AdmissiblePath.concat : {s t u : S} → AdmissiblePath C s t → AdmissiblePath C t u → AdmissiblePath C s u
  | _, _, _, nil _, q => q
  | _, _, _, cons h p, q => cons h (AdmissiblePath.concat p q)

theorem concat_nil_left {s t : S} (p : AdmissiblePath C s t) : AdmissiblePath.concat C (AdmissiblePath.nil s) p = p := by
  rfl

theorem concat_nil_right {s t : S} (p : AdmissiblePath C s t) : AdmissiblePath.concat C p (AdmissiblePath.nil t) = p := by
  induction p with
  | nil s => rfl
  | cons h p ih =>
    dsimp [AdmissiblePath.concat]
    rw [ih]

theorem concat_assoc {s t u v : S} (p : AdmissiblePath C s t) (q : AdmissiblePath C t u) (r : AdmissiblePath C u v) :
    AdmissiblePath.concat C (AdmissiblePath.concat C p q) r = AdmissiblePath.concat C p (AdmissiblePath.concat C q r) := by
  induction p with
  | nil s => rfl
  | cons h p ih =>
    dsimp [AdmissiblePath.concat]
    rw [ih]

theorem admissible_path_preservation {s t : S} (p : AdmissiblePath C s t) : π C s = π C t := by
  induction p with
  | nil s => rfl
  | cons h _ ih =>
    have h_step : π C _ = π C _ := identity_preservation C h
    exact h_step.trans ih

-- Define the concrete category
def ConcreteCategory (C : ConstitutionalSystem S I) : Type := S

instance (C : ConstitutionalSystem S I) : Category (ConcreteCategory C) where
  Hom s t := AdmissiblePath C s t
  id s := AdmissiblePath.nil s
  comp p q := AdmissiblePath.concat C p q
  id_comp p := concat_nil_left C p
  comp_id p := concat_nil_right C p
  assoc p q r := concat_assoc C p q r

-- Define the quotient category
def QuotientCategory (C : ConstitutionalSystem S I) : Type := Quot_ C

instance (C : ConstitutionalSystem S I) : Category (QuotientCategory C) where
  Hom q₁ q₂ := PLift (q₁ = q₂)
  id q := PLift.up rfl
  comp f g := PLift.up (f.down.trans g.down)
  id_comp := by
    intro X Y f
    cases f
    rfl
  comp_id := by
    intro X Y f
    cases f
    rfl
  assoc := by
    intro W X Y Z f g h
    cases f
    cases g
    cases h
    rfl

-- Construct the canonical projection functor
def projectionFunctor (C : ConstitutionalSystem S I) : ConcreteCategory C ⥤ QuotientCategory C where
  obj s := π C s
  map p := PLift.up (admissible_path_preservation C p)
  map_id s := by rfl
  map_comp f g := by rfl

-- Prove uniqueness up to natural isomorphism
def functor_iso (F : ConcreteCategory C ⥤ QuotientCategory C) (h_obj : ∀ s, F.obj s = π C s) : F ≅ projectionFunctor C where
  hom := {
    app := fun s => PLift.up (h_obj s)
    naturality := fun s t f => by rfl
  }
  inv := {
    app := fun s => PLift.up (h_obj s).symm
    naturality := fun s t f => by rfl
  }
  hom_inv_id := by
    ext s
    rfl
  inv_hom_id := by
    ext s
    rfl

-- Prove uniqueness up to functor equality (literal equality via Functor.ext)
theorem functor_eq (F : ConcreteCategory C ⥤ QuotientCategory C) (h_obj : ∀ s, F.obj s = π C s) : F = projectionFunctor C := by
  apply CategoryTheory.Functor.ext h_obj
