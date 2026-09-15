/-
  AGD FECU — Formal Execution–Complexity Collapse Under Verified Unfolding.

  Lean core constructions only. No unfinished-proof markers.
  Claim strength ≤ evidence strength.
  Does not assert a complexity-class collapse.

  Len-3 kernel:
    1. fecu_execution_preservation   π ∘ Tⁿ = T̄ⁿ ∘ π
    2. fecu_observable_preservation  Obs_X ∘ Tⁿ = Obs_Y ∘ T̄ⁿ ∘ π
    3. fecu_reconstruction_closure   π ∘ Tⁿ ∘ σ = T̄ⁿ
-/

namespace Chronofold.AGD.FECU

set_option autoImplicit false

universe u v w

variable {X : Type u} {Y : Type v} {O : Type w}

def iterate {α : Type u} (step : α → α) : Nat → α → α
  | 0,     x => x
  | n + 1, x => step (iterate step n x)

theorem iterate_zero {α : Type u} (step : α → α) (x : α) :
    iterate step 0 x = x :=
  rfl

theorem iterate_succ {α : Type u} (step : α → α) (n : Nat) (x : α) :
    iterate step (n + 1) x = step (iterate step n x) :=
  rfl

def Intertwines (T : X → X) (Tbar : Y → Y) (π : X → Y) : Prop :=
  ∀ x : X, π (T x) = Tbar (π x)

def SemPres (obsX : X → O) (obsY : Y → O) (π : X → Y) : Prop :=
  ∀ x : X, obsX x = obsY (π x)

def Section (π : X → Y) (σ : Y → X) : Prop :=
  ∀ y : Y, π (σ y) = y

def OCR (W_X : X → Nat) (W_Y : Y → Nat) (π : X → Y) (x : X) : Prop :=
  W_Y (π x) < W_X x

def CollapseAGD (sem : Prop) (Wred Wfull : Nat) : Prop :=
  sem ∧ Wred < Wfull

theorem fecu_execution_preservation
    (T : X → X) (Tbar : Y → Y) (π : X → Y)
    (hI : Intertwines T Tbar π) :
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
            = π (T (iterate T n x)) :=
          rfl
        _ = Tbar (π (iterate T n x)) :=
          hI (iterate T n x)
        _ = Tbar (iterate Tbar n (π x)) := by
          rw [ih x]
        _ = iterate Tbar (n + 1) (π x) :=
          rfl

theorem fecu_observable_preservation
    (T : X → X) (Tbar : Y → Y) (π : X → Y)
    (obsX : X → O) (obsY : Y → O)
    (hI : Intertwines T Tbar π)
    (hS : SemPres obsX obsY π) :
    ∀ n x, obsX (iterate T n x) = obsY (iterate Tbar n (π x)) := by
  intro n x
  calc
    obsX (iterate T n x)
        = obsY (π (iterate T n x)) :=
      hS (iterate T n x)
    _ = obsY (iterate Tbar n (π x)) := by
      rw [fecu_execution_preservation T Tbar π hI n x]

theorem fecu_section_id
    (π : X → Y) (σ : Y → X) (hSec : Section π σ) :
    π ∘ σ = id := by
  funext y
  exact hSec y

theorem fecu_pi_surjective
    (π : X → Y) (σ : Y → X) (hSec : Section π σ) :
    Function.Surjective π :=
  fun y => ⟨σ y, hSec y⟩

theorem fecu_reconstructed_operator
    (T : X → X) (Tbar : Y → Y) (π : X → Y) (σ : Y → X)
    (hI : Intertwines T Tbar π)
    (hSec : Section π σ) :
    π ∘ T ∘ σ = Tbar := by
  funext y
  calc
    (π ∘ T ∘ σ) y
        = π (T (σ y)) :=
      rfl
    _ = Tbar (π (σ y)) :=
      hI (σ y)
    _ = Tbar y := by
      rw [hSec y]

theorem fecu_reconstruction_closure
    (T : X → X) (Tbar : Y → Y) (π : X → Y) (σ : Y → X)
    (hI : Intertwines T Tbar π)
    (hSec : Section π σ) :
    ∀ n, π ∘ (fun x => iterate T n x) ∘ σ = fun y => iterate Tbar n y := by
  intro n
  funext y
  calc
    (π ∘ (fun x => iterate T n x) ∘ σ) y
        = π (iterate T n (σ y)) :=
      rfl
    _ = iterate Tbar n (π (σ y)) :=
      fecu_execution_preservation T Tbar π hI n (σ y)
    _ = iterate Tbar n y := by
      rw [hSec y]

theorem fecu_execution_chain
    (T : X → X) (Tbar : Y → Y) (π : X → Y) (σ : Y → X)
    (obsX : X → O) (obsY : Y → O)
    (hI : Intertwines T Tbar π)
    (hS : SemPres obsX obsY π)
    (hSec : Section π σ)
    (x0 : X) (n : Nat) :
    π (σ (iterate Tbar n (π x0))) = iterate Tbar n (π x0) ∧
    obsY (iterate Tbar n (π x0)) = obsX (iterate T n x0) := by
  constructor
  · exact hSec (iterate Tbar n (π x0))
  · exact (fecu_observable_preservation T Tbar π obsX obsY hI hS n x0).symm

def fullWork (m n k : Nat) : Nat :=
  2 * m * n * k

def quotientWork (r s k : Nat) : Nat :=
  2 * r * s * k

def workRatio (full reduced : Nat) : Nat :=
  full / reduced

theorem outer_factorization (q r s k : Nat) :
    fullWork (q * r) (q * s) k = q * q * quotientWork r s k := by
  unfold fullWork quotientWork
  simp [Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm]

theorem quotientWork_ne_zero
    {r s k : Nat} (hr : r ≠ 0) (hs : s ≠ 0) (hk : k ≠ 0) :
    quotientWork r s k ≠ 0 := by
  unfold quotientWork
  exact Nat.mul_ne_zero
    (Nat.mul_ne_zero (Nat.mul_ne_zero (Nat.succ_ne_zero 1) hr) hs) hk

theorem workRatio_outer
    (q r s k : Nat)
    (hr : r ≠ 0) (hs : s ≠ 0) (hk : k ≠ 0) :
    workRatio (fullWork (q * r) (q * s) k) (quotientWork r s k) = q * q := by
  unfold workRatio
  rw [outer_factorization, Nat.mul_comm (q * q)]
  exact Nat.mul_div_right (q * q)
    (Nat.pos_of_ne_zero (quotientWork_ne_zero hr hs hk))

theorem fullWork_1024 :
    fullWork 1024 1024 1024 = 2147483648 := by
  native_decide

theorem quotientWork_256 :
    quotientWork 256 256 1024 = 134217728 := by
  native_decide

theorem canonical_work_identity :
    fullWork 1024 1024 1024 = 16 * quotientWork 256 256 1024 := by
  native_decide

theorem canonical_strict_reduction :
    quotientWork 256 256 1024 < fullWork 1024 1024 1024 := by
  native_decide

theorem canonical_workRatio :
    workRatio (fullWork 1024 1024 1024) (quotientWork 256 256 1024) = 16 := by
  native_decide

theorem four_sq : (4 : Nat) * 4 = 16 := by
  native_decide

theorem dim_factorization : (1024 : Nat) = 4 * 256 := by
  native_decide

theorem canonical_is_q_square :
    workRatio (fullWork (4 * 256) (4 * 256) 1024) (quotientWork 256 256 1024)
      = 4 * 4 :=
  workRatio_outer 4 256 256 1024
    (by native_decide) (by native_decide) (by native_decide)

theorem work_split (a b c : Nat) (hba : b ≤ a) (hcb : c ≤ b) :
    a - c = (a - b) + (b - c) := by
  have hca : c ≤ a := Nat.le_trans hcb hba
  have hL : (a - c) + c = a := Nat.sub_add_cancel hca
  have hR : ((a - b) + (b - c)) + c = a := by
    rw [Nat.add_assoc, Nat.sub_add_cancel hcb, Nat.sub_add_cancel hba]
  exact Nat.add_right_cancel (hL.trans hR.symm)

theorem eliminated_work_decomposition
    (Wfull Wred : Nat) (hle : Wred ≤ Wfull) :
    Wfull = (Wfull - Wred) + Wred :=
  (Nat.sub_add_cancel hle).symm

def DiscoveryAdmissible
    (Cdiscover Wfull Wred N : Nat) : Prop :=
  Cdiscover < N * (Wfull - Wred)

theorem discovery_total_cost
    (Cdiscover Wfull Wred N : Nat)
    (hle : Wred ≤ Wfull)
    (hDisc : DiscoveryAdmissible Cdiscover Wfull Wred N) :
    Cdiscover + N * Wred < N * Wfull := by
  unfold DiscoveryAdmissible at hDisc
  have hdecomp : N * Wfull = N * (Wfull - Wred) + N * Wred := by
    rw [← Nat.mul_add, Nat.sub_add_cancel hle]
  rw [hdecomp]
  exact Nat.add_lt_add_right hDisc (N * Wred)

theorem monotone_cost_dominance
    (W Cfun : Nat → Nat)
    (hMono : ∀ a b, W a ≤ W b → Cfun a ≤ Cfun b)
    {a b : Nat} (h : W a ≤ W b) :
    Cfun a ≤ Cfun b :=
  hMono a b h

def Family (α : Type u) := α → Prop

def FamilyLocalOptimal {α : Type u} (W : α → Nat) (F : Family α) (m : α) : Prop :=
  F m ∧ ∀ x, F x → W m ≤ W x

theorem family_local_bound
    {α : Type u} (W : α → Nat) (F : Family α) (m x : α)
    (h : FamilyLocalOptimal W F m) (hx : F x) :
    W m ≤ W x :=
  h.2 x hx

structure FECUHypotheses
    (T : X → X) (Tbar : Y → Y)
    (π : X → Y) (σ : Y → X)
    (obsX : X → O) (obsY : Y → O)
    (W_X : X → Nat) (W_Y : Y → Nat) : Prop where
  intertwines : Intertwines T Tbar π
  observable : SemPres obsX obsY π
  reconstructs : Section π σ
  work_strict : ∀ x, OCR W_X W_Y π x

structure Len3Kernel
    (T : X → X) (Tbar : Y → Y)
    (π : X → Y) (σ : Y → X)
    (obsX : X → O) (obsY : Y → O) : Prop where
  execution :
    ∀ n x, π (iterate T n x) = iterate Tbar n (π x)
  observable :
    ∀ n x, obsX (iterate T n x) = obsY (iterate Tbar n (π x))
  reconstruction :
    ∀ n, π ∘ (fun x => iterate T n x) ∘ σ = fun y => iterate Tbar n y

theorem fecu_len3_certified
    (T : X → X) (Tbar : Y → Y)
    (π : X → Y) (σ : Y → X)
    (obsX : X → O) (obsY : Y → O)
    (hI : Intertwines T Tbar π)
    (hS : SemPres obsX obsY π)
    (hSec : Section π σ) :
    Len3Kernel T Tbar π σ obsX obsY where
  execution := fecu_execution_preservation T Tbar π hI
  observable := fecu_observable_preservation T Tbar π obsX obsY hI hS
  reconstruction := fecu_reconstruction_closure T Tbar π σ hI hSec

theorem fecu_theorem
    (T : X → X) (Tbar : Y → Y)
    (π : X → Y) (σ : Y → X)
    (obsX : X → O) (obsY : Y → O)
    (W_X : X → Nat) (W_Y : Y → Nat)
    (H : FECUHypotheses T Tbar π σ obsX obsY W_X W_Y) :
    (∀ n x, obsX (iterate T n x) = obsY (iterate Tbar n (π x))) ∧
    (π ∘ T ∘ σ = Tbar) ∧
    (∀ x, W_Y (π x) < W_X x) ∧
    (∀ n, π ∘ (fun x => iterate T n x) ∘ σ = fun y => iterate Tbar n y) ∧
    Function.Surjective π :=
  And.intro
    (fecu_observable_preservation T Tbar π obsX obsY H.intertwines H.observable)
    (And.intro
      (fecu_reconstructed_operator T Tbar π σ H.intertwines H.reconstructs)
      (And.intro H.work_strict
        (And.intro
          (fecu_reconstruction_closure T Tbar π σ H.intertwines H.reconstructs)
          (fecu_pi_surjective π σ H.reconstructs))))

theorem collapse_from_hypotheses
    (T : X → X) (Tbar : Y → Y)
    (π : X → Y) (σ : Y → X)
    (obsX : X → O) (obsY : Y → O)
    (W_X : X → Nat) (W_Y : Y → Nat)
    (H : FECUHypotheses T Tbar π σ obsX obsY W_X W_Y)
    (x : X) :
    CollapseAGD (obsX x = obsY (π x)) (W_Y (π x)) (W_X x) :=
  And.intro (H.observable x) (H.work_strict x)

theorem collapse_is_strict_not_zero
    (sem : Prop) (Wred Wfull : Nat)
    (hC : CollapseAGD sem Wred Wfull)
    (hpos : 0 < Wred) :
    0 < Wred ∧ Wred < Wfull :=
  And.intro hpos hC.2

def CanonicalWorkHolds : Prop :=
  fullWork 1024 1024 1024 = 2147483648 ∧
  quotientWork 256 256 1024 = 134217728 ∧
  fullWork 1024 1024 1024 = 16 * quotientWork 256 256 1024 ∧
  quotientWork 256 256 1024 < fullWork 1024 1024 1024 ∧
  workRatio (fullWork 1024 1024 1024) (quotientWork 256 256 1024) = 16 ∧
  workRatio (fullWork (4 * 256) (4 * 256) 1024) (quotientWork 256 256 1024) = 4 * 4

theorem canonical_work_closure : CanonicalWorkHolds :=
  And.intro fullWork_1024
    (And.intro quotientWork_256
      (And.intro canonical_work_identity
        (And.intro canonical_strict_reduction
          (And.intro canonical_workRatio canonical_is_q_square))))

def MaximalOperational
    (T : X → X) (Tbar : Y → Y)
    (π : X → Y) (σ : Y → X)
    (obsX : X → O) (obsY : Y → O)
    (W_X : X → Nat) (W_Y : Y → Nat) : Prop :=
  Intertwines T Tbar π ∧
  SemPres obsX obsY π ∧
  Section π σ ∧
  (∀ n x, π (iterate T n x) = iterate Tbar n (π x)) ∧
  (∀ n x, obsX (iterate T n x) = obsY (iterate Tbar n (π x))) ∧
  (π ∘ T ∘ σ = Tbar) ∧
  (∀ n, π ∘ (fun x => iterate T n x) ∘ σ = fun y => iterate Tbar n y) ∧
  Function.Surjective π ∧
  (∀ x, W_Y (π x) < W_X x) ∧
  CanonicalWorkHolds

theorem fecu_maximal_operational_claim
    (T : X → X) (Tbar : Y → Y)
    (π : X → Y) (σ : Y → X)
    (obsX : X → O) (obsY : Y → O)
    (W_X : X → Nat) (W_Y : Y → Nat)
    (H : FECUHypotheses T Tbar π σ obsX obsY W_X W_Y) :
    MaximalOperational T Tbar π σ obsX obsY W_X W_Y :=
  let K := fecu_len3_certified T Tbar π σ obsX obsY
    H.intertwines H.observable H.reconstructs
  And.intro H.intertwines
    (And.intro H.observable
      (And.intro H.reconstructs
        (And.intro K.execution
          (And.intro K.observable
            (And.intro
              (fecu_reconstructed_operator T Tbar π σ H.intertwines H.reconstructs)
              (And.intro K.reconstruction
                (And.intro (fecu_pi_surjective π σ H.reconstructs)
                  (And.intro H.work_strict canonical_work_closure))))))))

structure EvidenceBoundary where
  formalClaimEstablished : Bool
  runtimeMeasured : Bool
  runtimeReproducible : Bool
  runtimeHashBound : Bool

def publishable (B : EvidenceBoundary) : Prop :=
  B.formalClaimEstablished = true ∧
  B.runtimeMeasured = true ∧
  B.runtimeReproducible = true ∧
  B.runtimeHashBound = true

theorem unpublished_if_formal_missing
    (B : EvidenceBoundary)
    (h : B.formalClaimEstablished = false) :
    ¬ publishable B := by
  intro hp
  have : B.formalClaimEstablished = true := hp.1
  rw [h] at this
  cases this

def runtimeRatio (num den : Nat) : Nat :=
  num / den

theorem formal_work_is_not_runtime :
    runtimeRatio 1596 100 ≠
      workRatio (fullWork 1024 1024 1024) (quotientWork 256 256 1024) := by
  native_decide

end Chronofold.AGD.FECU
