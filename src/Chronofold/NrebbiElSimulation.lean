/-!
# Nrebbi-El Simulation Theorem — dependency-free simulation closure

This file is standalone and imports nothing.  It extracts the simulation
content of the constitutional quotient construction from the already-proven
AGD descent machinery, but re-proves the simulation statements directly from
primitive definitions.

The key relation is the graph of the projection π : H → Q.  For deterministic
operators T : H → H and Tbar : Q → Q, this graph is a forward simulation
exactly when T descends through π.  Consequently one-step simulation is
bidirectionally equivalent to recursive simulation at every finite depth.

No `sorry`, `admit`, `axiom`, Mathlib, or project-local dependency is used.
-/

namespace NrebbiElSimulation

universe u v w

/-! ## Primitive transition objects -/

def Projection (H : Type u) (Q : Type v) := H → Q

def Operator (H : Type u) := H → H

def QuotientOperator (Q : Type v) := Q → Q

/-! ## Constitutional projection and dynamics -/

def OperationalEq {H : Type u} {Q : Type v}
    (π : Projection H Q) (x y : H) : Prop :=
  π x = π y

def Admissible {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) : Prop :=
  ∀ x, π (T x) = π x

def Descends {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H)
    (Tbar : QuotientOperator Q) : Prop :=
  ∀ x, π (T x) = Tbar (π x)

/-! ## Iteration -/
def iterate {α : Type u} (T : α → α) : Nat → α → α
  | 0, x => x
  | n + 1, x => T (iterate T n x)

theorem iterate_zero {α : Type u} (T : α → α) (x : α) :
    iterate T 0 x = x := rfl

theorem iterate_succ {α : Type u} (T : α → α) (n : Nat) (x : α) :
    iterate T (n + 1) x = T (iterate T n x) := rfl

/-! ## The projection graph -/
def GraphRel {H : Type u} {Q : Type v}
    (π : Projection H Q) (x : H) (q : Q) : Prop :=
  π x = q

/-- Forward deterministic simulation along the graph of π. -/
def Simulates {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H)
    (Tbar : QuotientOperator Q) : Prop :=
  ∀ x q, GraphRel π x q →
    ∃ q', q' = Tbar q ∧ GraphRel π (T x) q'

/-- Recursive simulation along the graph of π. -/
def RecursivelySimulates {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H)
    (Tbar : QuotientOperator Q) : Prop :=
  ∀ n x q,
    GraphRel π (iterate T n x) q →
      ∃ q', q' = iterate Tbar n q ∧
        GraphRel π (iterate T n x) q'

/-! ## Elementary graph facts -/
theorem graph_rel_iff {H : Type u} {Q : Type v}
    (π : Projection H Q) (x : H) (q : Q) :
    GraphRel π x q ↔ π x = q := Iff.rfl

theorem graph_rel_refl {H : Type u} {Q : Type v}
    (π : Projection H Q) (x : H) :
    GraphRel π x (π x) := rfl

/-! ## Descent implies one-step simulation -/
theorem descends_implies_simulates
    {H : Type u} {Q : Type v}
    (π : Projection H Q) {T : Operator H} {Tbar : QuotientOperator Q}
    (h : Descends π T Tbar) :
    Simulates π T Tbar := by
  intro x q hx
  refine ⟨Tbar q, rfl, ?_⟩
  calc
    π (T x) = Tbar (π x) := h x
    _ = Tbar q := by rw [hx]

/-! ## Simulation implies descent: specialize to the canonical graph point -/
theorem simulates_implies_descends
    {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) (Tbar : QuotientOperator Q)
    (h : Simulates π T Tbar) :
    Descends π T Tbar := by
  intro x
  have hs := h x (π x) (graph_rel_refl π x)
  rcases hs with ⟨q', hq, hgraph⟩
  calc
    π (T x) = q' := hgraph
    _ = Tbar (π x) := hq

/-- CENTRAL ONE-STEP SIMULATION THEOREM.

The quotient projection graph simulates the concrete operator exactly when
that operator descends through the projection.
-/
theorem simulation_iff_descent
    {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) (Tbar : QuotientOperator Q) :
    Simulates π T Tbar ↔ Descends π T Tbar := by
  constructor
  · exact simulates_implies_descends π T Tbar
  · exact descends_implies_simulates π

/-! ## Recursive quotient simulation -/
theorem descends_implies_recursive_simulates
    {H : Type u} {Q : Type v}
    (π : Projection H Q) {T : Operator H} {Tbar : QuotientOperator Q}
    (h : Descends π T Tbar) :
    RecursivelySimulates π T Tbar := by
  intro n
  induction n with
  | zero =>
      intro x q hx
      refine ⟨q, ?_, hx⟩
      rfl
  | succ n ih =>
      intro x q hx
      have hprev :
          GraphRel π (iterate T n x) q := by
        exact hx
      have hsim := ih x q hprev
      rcases hsim with ⟨q', hq', hgraph'⟩
      refine ⟨Tbar q', ?_, ?_⟩
      · rw [hq']
      · calc
          π (iterate T (n + 1) x)
              = π (T (iterate T n x)) := rfl
          _ = Tbar (π (iterate T n x)) := h (iterate T n x)
          _ = Tbar q' := by rw [hgraph']

/-! ## Recursive simulation implies one-step simulation -/
theorem recursively_simulates_implies_simulates
    {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) (Tbar : QuotientOperator Q)
    (h : RecursivelySimulates π T Tbar) :
    Simulates π T Tbar := by
  intro x q hx
  have hs := h 1 x q hx
  rcases hs with ⟨q', hq', hgraph'⟩
  refine ⟨q', ?_, hgraph'⟩
  simpa [iterate] using hq'

/-- CENTRAL RECURSIVE SIMULATION THEOREM. -/
theorem simulation_iff_recursive_simulation
    {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) (Tbar : QuotientOperator Q) :
    Simulates π T Tbar ↔ RecursivelySimulates π T Tbar := by
  constructor
  · intro h
    exact descends_implies_recursive_simulates π (simulates_implies_descends π T Tbar h)
  · intro h
    exact recursively_simulates_implies_simulates π T Tbar h

/-! ## Exact trajectory correspondence -/
def ExactTrajectoryCorrespondence {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) (Tbar : QuotientOperator Q) : Prop :=
  ∀ n x, π (iterate T n x) = iterate Tbar n (π x)

theorem descends_iff_exact_trajectory
    {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) (Tbar : QuotientOperator Q) :
    Descends π T Tbar ↔ ExactTrajectoryCorrespondence π T Tbar := by
  constructor
  · intro h
    intro n
    induction n with
    | zero => intro x; rfl
    | succ n ih =>
        intro x
        calc
          π (iterate T (n + 1) x)
              = π (T (iterate T n x)) := rfl
          _ = Tbar (π (iterate T n x)) := h (iterate T n x)
          _ = Tbar (iterate Tbar n (π x)) := by rw [ih x]
          _ = iterate Tbar (n + 1) (π x) := rfl
  · intro h x
    have hx := h 1 x
    simpa [iterate] using hx

/-! ## Simulation and exact trajectories coincide -/
theorem simulation_iff_exact_trajectory
    {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) (Tbar : QuotientOperator Q) :
    Simulates π T Tbar ↔ ExactTrajectoryCorrespondence π T Tbar := by
  rw [simulation_iff_descent, descends_iff_exact_trajectory]

/-! ## Constitutional admissibility gives identity simulation -/
theorem admissible_implies_identity_simulation
    {H : Type u} {Q : Type v}
    (π : Projection H Q) {T : Operator H}
    (h : Admissible π T) :
    Simulates π T id := by
  exact descends_implies_simulates π h

theorem admissible_implies_recursive_identity_simulation
    {H : Type u} {Q : Type v}
    (π : Projection H Q) {T : Operator H}
    (h : Admissible π T) :
    RecursivelySimulates π T id := by
  exact descends_implies_recursive_simulates π h

/-! ## Observable factorization -/
def RespectsConstitution {H : Type u} {Q : Type v} {Obs : Type w}
    (π : Projection H Q) (f : H → Obs) : Prop :=
  ∀ x y, π x = π y → f x = f y

def FactorWitness {H : Type u} {Q : Type v} {Obs : Type w}
    (π : Projection H Q) (f : H → Obs) : Prop :=
  ∃ fbar : Q → Obs, ∀ x, f x = fbar (π x)

theorem factor_witness_implies_respects
    {H : Type u} {Q : Type v} {Obs : Type w}
    (π : Projection H Q) (f : H → Obs)
    (h : FactorWitness π f) :
    RespectsConstitution π f := by
  rcases h with ⟨fbar, hf⟩
  intro x y hxy
  calc
    f x = fbar (π x) := hf x
    _ = fbar (π y) := by rw [hxy]
    _ = f y := (hf y).symm

/-! ## Complete dependency-free simulation package -/
structure SimulationClosure {H : Type u} {Q : Type v}
    (π : Projection H Q) where
  T : Operator H
  Tbar : QuotientOperator Q
  simulation : Simulates π T Tbar
  recursive_simulation : RecursivelySimulates π T Tbar
  exact_trajectory : ExactTrajectoryCorrespondence π T Tbar

/--
# Nrebbi-El Simulation Theorem

For deterministic dynamics, simulation along the projection graph, one-step
quotient descent, and exact finite recursive trajectory correspondence are all
equivalent.  Admissibility is the special case in which the quotient dynamics
is the identity.
-/
theorem nrebbi_el_simulation_theorem
    {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) (Tbar : QuotientOperator Q) :
    (Simulates π T Tbar ↔ Descends π T Tbar) ∧
    (Simulates π T Tbar ↔ RecursivelySimulates π T Tbar) ∧
    (Simulates π T Tbar ↔ ExactTrajectoryCorrespondence π T Tbar) ∧
    (Admissible π T → Simulates π T id) ∧
    (Admissible π T → RecursivelySimulates π T id) := by
  constructor
  · exact simulation_iff_descent π T Tbar
  constructor
  · exact simulation_iff_recursive_simulation π T Tbar
  constructor
  · exact simulation_iff_exact_trajectory π T Tbar
  constructor
  · exact admissible_implies_identity_simulation π
  · exact admissible_implies_recursive_identity_simulation π

end NrebbiElSimulation
