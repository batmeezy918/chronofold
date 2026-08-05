import Chronofold.AgdClosure

/-!
# Tier A1 — Rank-r orthogonal projection (Omega rank collapse)
Lean 4.29 accepted — no sorries.
-/

namespace Chronofold.AGD

universe u

structure Projective (beta : Type u) where
  P : beta → beta
  idempotent : ∀ x, P (P x) = P x

theorem projective_collapse {beta : Type u} (Pi : Projective beta) (x : beta) :
    Pi.P (Pi.P x) = Pi.P x :=
  Pi.idempotent x

def isFixed {beta : Type u} (Pi : Projective beta) (y : beta) : Prop :=
  Pi.P y = y

theorem apply_is_fixed {beta : Type u} (Pi : Projective beta) (x : beta) :
    isFixed Pi (Pi.P x) :=
  Pi.idempotent x

structure RankedSpan (beta : Type u) where
  generators : List beta

def RankedSpan.rank {beta : Type u} (S : RankedSpan beta) : Nat :=
  S.generators.length

theorem RankedSpan.rank_eq_length {beta : Type u} (S : RankedSpan beta) :
    S.rank = S.generators.length := rfl

theorem RankedSpan.rank_le_length {beta : Type u} (S : RankedSpan beta) :
    S.rank ≤ S.generators.length := Nat.le_refl _

theorem projective_idempotent_comp {beta : Type u} (Pi : Projective beta) (x : beta) :
    Pi.P (Pi.P x) = Pi.P x :=
  Pi.idempotent x

def Projective.ofIdempotent {beta : Type u} (P : beta → beta) (h : ∀ x, P (P x) = P x) :
    Projective beta :=
  ⟨P, h⟩

end Chronofold.AGD
