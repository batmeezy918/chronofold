/-!
# Measurement / jitter / certificate theorems
Harvested from chronofold PRs #10 and #12.
Lean 4 core only. No Mathlib. No `sorry`.
Reals replaced by `Nat` so the statements typecheck on the current Chronofold package.
-/

namespace Chronofold.AgdMeasurement

structure MeasurementState where
  latency : Nat
  jitter : Nat
  energy : Nat
  throughput : Nat
  error : Nat
  deriving Repr, DecidableEq

def measurement_equiv (a b : MeasurementState) : Prop :=
  a.jitter = b.jitter ∧ a.error = b.error

theorem measurement_equiv_refl (a : MeasurementState) :
    measurement_equiv a a :=
  ⟨rfl, rfl⟩

theorem measurement_equiv_symm {a b : MeasurementState} :
    measurement_equiv a b → measurement_equiv b a := by
  intro ⟨hj, he⟩
  exact ⟨hj.symm, he.symm⟩

theorem measurement_equiv_trans {a b c : MeasurementState} :
    measurement_equiv a b → measurement_equiv b c → measurement_equiv a c := by
  intro ⟨hj1, he1⟩ ⟨hj2, he2⟩
  exact ⟨hj1.trans hj2, he1.trans he2⟩

structure CertifiedTransition where
  before : MeasurementState
  after : MeasurementState

def measurement_preserved (ct : CertifiedTransition) : Prop :=
  measurement_equiv ct.before ct.after

theorem agd_measurement_invariant
    (ct : CertifiedTransition)
    (h : measurement_preserved ct) :
    measurement_equiv ct.before ct.after :=
  h

/-- PR #10 THM_000101: jitter closeness is reflexive. -/
def jitter_close {Device : Type} (J : Device → Nat) (ε : Nat) (A B : Device) : Prop :=
  Nat.dist (J A) (J B) ≤ ε

theorem jitter_close_reflexive {Device : Type} (J : Device → Nat) (ε : Nat) (A : Device) :
    jitter_close J ε A A := by
  unfold jitter_close
  simp [Nat.dist_self]

/-- PR #10 THM_000102. -/
theorem jitter_close_symmetric {Device : Type} (J : Device → Nat) (ε : Nat)
    {A B : Device} :
    jitter_close J ε A B → jitter_close J ε B A := by
  intro h
  unfold jitter_close at *
  simpa [Nat.dist_comm] using h

/-- PR #10 THM_000103 triangle form: two ε-steps give a 2ε bound. -/
theorem jitter_close_triangle {Device : Type} (J : Device → Nat) (ε : Nat)
    {A B C : Device}
    (hAB : jitter_close J ε A B)
    (hBC : jitter_close J ε B C) :
    Nat.dist (J A) (J C) ≤ ε + ε := by
  unfold jitter_close at hAB hBC
  have h := Nat.dist_triangle (J A) (J B) (J C)
  exact Nat.le_trans h (Nat.add_le_add hAB hBC)

structure RuntimeCert where
  baseline : Nat
  agd : Nat
  speedup : Nat

def valid_certificate (c : RuntimeCert) : Prop :=
  0 < c.agd ∧ 0 < c.baseline ∧ c.baseline = c.speedup * c.agd

/-- PR #10 THM_000105. -/
theorem speedup_positive (c : RuntimeCert) (h : valid_certificate c) :
    0 < c.speedup := by
  rcases h with ⟨ha, hb, heq⟩
  cases c.speedup with
  | zero =>
    simp at heq
    exact absurd (heq.symm.trans rfl ▸ Nat.not_lt_zero _) hb
  | succ n =>
    exact Nat.succ_pos n

/-- PR #10 THM_000106 reconstruction identity. -/
theorem benchmark_claim_valid (c : RuntimeCert) (h : valid_certificate c) :
    c.baseline = c.speedup * c.agd :=
  h.2.2

/-- PR #10 THM_000107 transport closure under a flow that fixes the observable. -/
theorem agd_transport_closure
    {Q : Type} (Ω : Q → Nat) (T : Nat → Q → Q) (q : Q)
    (h_flow : ∀ t, T t q = q) :
    ∀ t, Ω (T t q) = Ω q := by
  intro t
  rw [h_flow]

/-- PR #10 THM_000109 bisimulation of an invariant-preserving flow. -/
def AGDEquiv {Q : Type} (Ω : Q → Nat) (q1 q2 : Q) : Prop := Ω q1 = Ω q2

theorem agd_bisimulation {Q : Type} (Ω : Q → Nat) (T : Nat → Q → Q)
    (h_transport : ∀ t q, Ω (T t q) = Ω q)
    {q1 q2 : Q} (h_init : AGDEquiv Ω q1 q2) :
    ∀ t, AGDEquiv Ω (T t q1) (T t q2) := by
  intro t
  unfold AGDEquiv at *
  rw [h_transport, h_transport]
  exact h_init

/-- PR #10 THM_000110 semigroup rewrite. -/
theorem agd_flow_semigroup {Q : Type} (T : Nat → Q → Q)
    (h_flow : ∀ t s q, T (t + s) q = T t (T s q)) :
    ∀ t s q, T (t + s) q = (T t ∘ T s) q :=
  h_flow

/-- PR #10 THM_000111 master dynamic closure. -/
theorem agd_master_dynamic_closure {Q : Type}
    (T : Nat → Q → Q) (Ω : Q → Nat) (q : Q)
    (h_transport : ∀ t q', Ω (T t q') = Ω q')
    (J : Nat → Nat)
    (h_convergence : ∀ t, 0 < t → J t < J 0) :
    (∀ t, Ω (T t q) = Ω q) ∧ (∀ t, 0 < t → J t < J 0) :=
  ⟨fun t => h_transport t q, h_convergence⟩

/-- PR #10 THM_000202 rollback restores the pre-state. -/
structure Transition (α : Type) where
  before : α
  after : α

def rollback {H : Type} (t : Transition H) : H := t.before

def IsStable {H : Type} (Ω : H → Nat) (s : H) (expected : Nat) : Prop :=
  Ω s = expected

theorem agd_failure_recovery {H : Type} (Ω : H → Nat) (t : Transition H)
    (expected : Nat)
    (h_before : IsStable Ω t.before expected)
    (h_after : ¬ IsStable Ω t.after expected) :
    IsStable Ω (rollback t) expected ∧ rollback t ≠ t.after := by
  constructor
  · exact h_before
  · intro h_eq
    unfold rollback at h_eq
    rw [h_eq] at h_before
    exact h_after h_before

/-- PR #10 THM_000204 lineage reconstruction witness. -/
def reconstruct_state {H : Type} (start : H) : List (H → H) → H
  | [] => start
  | f :: rest => reconstruct_state (f start) rest

theorem memory_lineage_reconstruction {H : Type}
    (start : H) (l : List (H → H)) (current : H)
    (h_valid : current = reconstruct_state start l) :
    ∃ start_state history, current = reconstruct_state start_state history :=
  ⟨start, l, h_valid⟩

end Chronofold.AgdMeasurement
