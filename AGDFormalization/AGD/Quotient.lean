import AGD.State
import Mathlib.Data.Setoid.Basic

variable {H : Type*}

/-- AGD Equivalence relation: s1 ≈AGD s2 iff they have identical signatures. -/
def AGD_Equiv (s1 s2 : AGDState H) : Prop :=
  s1.omega = s2.omega ∧ s1.cov = s2.cov

/-- Setoid instance for AGDState. -/
instance AGD_Setoid (H : Type*) : Setoid (AGDState H) where
  r := AGD_Equiv
  iseqv := {
    refl := fun _ => ⟨rfl, rfl⟩
    symm := fun h => ⟨h.1.symm, h.2.symm⟩
    trans := fun h1 h2 => ⟨h1.1.trans h2.1, h1.2.trans h2.2⟩
  }

/-- Canonical Quotient space of AGDStates. -/
def AGDQuotient (H : Type*) := Quotient (AGD_Setoid H)

/-- Projection from State to Quotient. -/
def Pi (s : AGDState H) : AGDQuotient H := Quotient.mk (AGD_Setoid H) s

/-- Theorem: Pi(s1) = Pi(s2) iff s1 ≈AGD s2. -/
theorem pi_sound_and_complete (s1 s2 : AGDState H) :
  Pi s1 = Pi s2 ↔ AGD_Equiv s1 s2 :=
  Quotient.eq
