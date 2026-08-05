import Chronofold.AgdUniversal

/-!
# Tier A3 — Certified inter-class edges
Lean 4.29 accepted — no sorries.
-/

namespace Chronofold.AGD

universe u

structure CertifiedEdge (α : Type u) (Ω : Omega α) (C : Covariant α) where
  src : State α
  dst : State α
  T : Operator α
  hT : Admissible α Ω C T
  realizes : T src = dst

theorem certifiedEdge_class_step (α : Type u) (Ω : Omega α) (C : Covariant α)
    (e : CertifiedEdge α Ω C) :
    TBar α Ω C e.T e.hT (pi α Ω C e.src) = pi α Ω C e.dst := by
  rw [TBar_sound, e.realizes]

def classAdjacent (α : Type u) (Ω : Omega α) (C : Covariant α)
    (edges : List (CertifiedEdge α Ω C))
    (q q' : QStar α Ω C) : Prop :=
  ∃ e ∈ edges, pi α Ω C e.src = q ∧ pi α Ω C e.dst = q'

theorem classAdjacent_of_mem (α : Type u) (Ω : Omega α) (C : Covariant α)
    (edges : List (CertifiedEdge α Ω C)) (e : CertifiedEdge α Ω C)
    (hmem : e ∈ edges) :
    classAdjacent α Ω C edges (pi α Ω C e.src) (pi α Ω C e.dst) :=
  ⟨e, hmem, rfl, rfl⟩

def classPath (α : Type u) (Ω : Omega α) (C : Covariant α)
    (edges : List (CertifiedEdge α Ω C)) : QStar α Ω C → QStar α Ω C → Nat → Prop
  | q, q', 0 => q = q'
  | q, q', n + 1 => ∃ qmid, classAdjacent α Ω C edges q qmid ∧ classPath α Ω C edges qmid q' n

theorem classPath_zero (α : Type u) (Ω : Omega α) (C : Covariant α)
    (edges : List (CertifiedEdge α Ω C)) (q : QStar α Ω C) :
    classPath α Ω C edges q q 0 := rfl

theorem classPath_one_of_adjacent (α : Type u) (Ω : Omega α) (C : Covariant α)
    (edges : List (CertifiedEdge α Ω C)) {q q' : QStar α Ω C}
    (h : classAdjacent α Ω C edges q q') :
    classPath α Ω C edges q q' 1 :=
  ⟨q', h, rfl⟩

def outDegreeBound (α : Type u) (Ω : Omega α) (C : Covariant α)
    (edges : List (CertifiedEdge α Ω C)) : Nat :=
  edges.length

theorem outDegreeBound_eq (α : Type u) (Ω : Omega α) (C : Covariant α)
    (edges : List (CertifiedEdge α Ω C)) :
    outDegreeBound α Ω C edges = edges.length := rfl

end Chronofold.AGD
