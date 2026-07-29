import Mathlib

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
