import Chronofold.AgdCore

/-!
# Constitutional Kernel T0.1–T0.6 (maximal operational scope)

Non-vacuous Phase-0 kernel. Predicates are not `True`.
Ω is the conjunction of five independent invariants on a concrete state.
Admissible operators preserve each conjunct, hence preserve Ω and finite chains.

No Mathlib. No unfinished goals. No extra axioms.
Does not claim EMVCo certification or payment semantics.
-/

namespace Chronofold.ConstitutionalKernelT0

structure State where
  id    : Nat
  ns    : Nat
  ver   : Nat
  prov  : Nat
  nodes : List Nat
  edges : List (Nat × Nat)
  deriving DecidableEq, Repr

abbrev Operator := State → State

def namespace_valid (psi : State) : Prop := psi.ns ≠ 0
def version_valid (psi : State) : Prop := psi.ver ≠ 0
def provenance_valid (psi : State) : Prop := psi.prov ≠ 0

def endpoints_resolved (psi : State) : Prop :=
  ∀ e ∈ psi.edges, e.1 ∈ psi.nodes ∧ e.2 ∈ psi.nodes

def stratified (psi : State) : Prop :=
  ∀ e ∈ psi.edges, e.2 < e.1

def all_relationships_resolve (psi : State) : Prop := endpoints_resolved psi
def acyclic_relationships (psi : State) : Prop := stratified psi

structure Omega (psi : State) : Prop where
  ns   : namespace_valid psi
  ver  : version_valid psi
  prov : provenance_valid psi
  rel  : all_relationships_resolve psi
  acyc : acyclic_relationships psi

def admissible_state (psi : State) : Prop := Omega psi

def namespace_preserving (O : Operator) : Prop :=
  ∀ psi, namespace_valid psi → namespace_valid (O psi)

def version_preserving (O : Operator) : Prop :=
  ∀ psi, version_valid psi → version_valid (O psi)

def provenance_preserving (O : Operator) : Prop :=
  ∀ psi, provenance_valid psi → provenance_valid (O psi)

def relationship_preserving (O : Operator) : Prop :=
  ∀ psi, all_relationships_resolve psi → all_relationships_resolve (O psi)

def acyclicity_preserving (O : Operator) : Prop :=
  ∀ psi, acyclic_relationships psi → acyclic_relationships (O psi)

def deterministic (O : Operator) : Prop := ∀ psi phi, psi = phi → O psi = O phi
def replayable (O : Operator) : Prop := ∀ psi, O psi = O psi
def traceable (O : Operator) : Prop := ∀ psi, ∃ phi, phi = O psi

def admissible_operator (O : Operator) : Prop :=
  deterministic O ∧ replayable O ∧ traceable O ∧
  namespace_preserving O ∧ version_preserving O ∧ provenance_preserving O ∧
  relationship_preserving O ∧ acyclicity_preserving O

theorem T0_1_namespace_preservation
    (O : Operator) (hO : namespace_preserving O) :
    ∀ psi, namespace_valid psi → namespace_valid (O psi) := hO

theorem T0_2_version_preservation
    (O : Operator) (hO : version_preserving O) :
    ∀ psi, version_valid psi → version_valid (O psi) := hO

theorem T0_3_provenance_preservation
    (O : Operator) (hO : provenance_preserving O) :
    ∀ psi, provenance_valid psi → provenance_valid (O psi) := hO

theorem T0_4_relationship_resolution_preservation
    (O : Operator) (hO : relationship_preserving O) :
    ∀ psi, all_relationships_resolve psi → all_relationships_resolve (O psi) := hO

theorem T0_5_acyclicity_preservation
    (O : Operator) (hO : acyclicity_preserving O) :
    ∀ psi, acyclic_relationships psi → acyclic_relationships (O psi) := hO

theorem T0_6_omega_preservation
    (psi : State) (O : Operator)
    (hN : namespace_preserving O) (hV : version_preserving O)
    (hP : provenance_preserving O) (hR : relationship_preserving O)
    (hA : acyclicity_preserving O) (hOmg : Omega psi) :
    Omega (O psi) :=
  ⟨T0_1_namespace_preservation O hN psi hOmg.ns,
   T0_2_version_preservation O hV psi hOmg.ver,
   T0_3_provenance_preservation O hP psi hOmg.prov,
   T0_4_relationship_resolution_preservation O hR psi hOmg.rel,
   T0_5_acyclicity_preservation O hA psi hOmg.acyc⟩

theorem T0_6_omega_characterization (psi : State) :
    Omega psi ↔
      namespace_valid psi ∧ version_valid psi ∧ provenance_valid psi ∧
      all_relationships_resolve psi ∧ acyclic_relationships psi := by
  constructor
  · intro h; exact ⟨h.ns, h.ver, h.prov, h.rel, h.acyc⟩
  · intro h; exact ⟨h.1, h.2.1, h.2.2.1, h.2.2.2.1, h.2.2.2.2⟩

theorem admissibility_closure
    (psi : State) (hpsi : admissible_state psi)
    (O : Operator) (hO : admissible_operator O) :
    admissible_state (O psi) :=
  T0_6_omega_preservation psi O hO.2.2.2.1 hO.2.2.2.2.1
    hO.2.2.2.2.2.1 hO.2.2.2.2.2.2.1 hO.2.2.2.2.2.2.2 hpsi

def compose (O1 O2 : Operator) : Operator := fun s => O1 (O2 s)
def id_op : Operator := fun s => s

theorem deterministic_all (O : Operator) : deterministic O := by
  intro psi phi h; exact congrArg O h

theorem replayable_all (O : Operator) : replayable O := by
  intro psi; rfl

theorem traceable_all (O : Operator) : traceable O := by
  intro psi; exact ⟨O psi, rfl⟩

theorem identity_operator_admissible : admissible_operator id_op := by
  refine ⟨deterministic_all id_op, replayable_all id_op, traceable_all id_op, ?_, ?_, ?_, ?_, ?_⟩
  · intro psi h; exact h
  · intro psi h; exact h
  · intro psi h; exact h
  · intro psi h; exact h
  · intro psi h; exact h

theorem operator_composition_associative (O1 O2 O3 : Operator) :
    compose (compose O1 O2) O3 = compose O1 (compose O2 O3) := rfl

theorem operator_composition_closed
    (O1 O2 : Operator) (h1 : admissible_operator O1) (h2 : admissible_operator O2) :
    admissible_operator (compose O1 O2) := by
  refine ⟨deterministic_all _, replayable_all _, traceable_all _, ?_, ?_, ?_, ?_, ?_⟩
  · intro psi hpsi; exact h1.2.2.2.1 (O2 psi) (h2.2.2.2.1 psi hpsi)
  · intro psi hpsi; exact h1.2.2.2.2.1 (O2 psi) (h2.2.2.2.2.1 psi hpsi)
  · intro psi hpsi; exact h1.2.2.2.2.2.1 (O2 psi) (h2.2.2.2.2.2.1 psi hpsi)
  · intro psi hpsi; exact h1.2.2.2.2.2.2.1 (O2 psi) (h2.2.2.2.2.2.2.1 psi hpsi)
  · intro psi hpsi; exact h1.2.2.2.2.2.2.2 (O2 psi) (h2.2.2.2.2.2.2.2 psi hpsi)

def iterate (O : Operator) : Nat → Operator
  | 0 => id_op
  | n + 1 => compose O (iterate O n)

theorem iterate_admissible (O : Operator) (hO : admissible_operator O) :
    ∀ n, admissible_operator (iterate O n)
  | 0 => identity_operator_admissible
  | n + 1 => operator_composition_closed O (iterate O n) hO (iterate_admissible O hO n)

def apply_chain : List Operator → State → State
  | [], psi => psi
  | O :: Os, psi => apply_chain Os (O psi)

theorem constitutional_closure
    (psi : State) (hpsi : admissible_state psi)
    (Os : List Operator) (hOs : ∀ O, O ∈ Os → admissible_operator O) :
    admissible_state (apply_chain Os psi) := by
  induction Os generalizing psi with
  | nil => exact hpsi
  | cons O Os ih =>
    have hO : admissible_operator O := hOs O (List.Mem.head Os)
    have hOpsi : admissible_state (O psi) := admissibility_closure psi hpsi O hO
    have hRest : ∀ O', O' ∈ Os → admissible_operator O' :=
      fun O' h => hOs O' (List.Mem.tail O h)
    exact ih (O psi) hOpsi hRest

def bit (p : Prop) [Decidable p] : Nat := if p then 0 else 1

instance (psi : State) : Decidable (namespace_valid psi) :=
  inferInstanceAs (Decidable (psi.ns ≠ 0))
instance (psi : State) : Decidable (version_valid psi) :=
  inferInstanceAs (Decidable (psi.ver ≠ 0))
instance (psi : State) : Decidable (provenance_valid psi) :=
  inferInstanceAs (Decidable (psi.prov ≠ 0))

def D_coord (psi : State) : Nat :=
  bit (namespace_valid psi) + bit (version_valid psi) + bit (provenance_valid psi)

theorem D_coord_zero_of_omega (psi : State) (h : Omega psi) : D_coord psi = 0 := by
  simp [D_coord, bit, h.ns, h.ver, h.prov]

theorem defect_zero_of_admissible
    (psi : State) (h : admissible_state psi) (O : Operator) (hO : admissible_operator O) :
    D_coord (O psi) = 0 :=
  D_coord_zero_of_omega (O psi) (admissibility_closure psi h O hO)

def initial : State :=
  { id := 0, ns := 1, ver := 1, prov := 1, nodes := [0], edges := [] }

theorem initial_omega : Omega initial := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · simp [namespace_valid, initial]
  · simp [version_valid, initial]
  · simp [provenance_valid, initial]
  · intro e he; cases he
  · intro e he; cases he

def stampVersion (n : Nat) : Operator :=
  fun psi => { psi with ver := psi.ver + n }

def addNode (x : Nat) : Operator :=
  fun psi => { psi with nodes := x :: psi.nodes }

def wipeNs : Operator :=
  fun psi => { psi with ns := 0 }

theorem stampVersion_admissible (n : Nat) :
    admissible_operator (stampVersion n) := by
  refine ⟨deterministic_all _, replayable_all _, traceable_all _, ?_, ?_, ?_, ?_, ?_⟩
  · intro psi h; exact h
  · intro psi h
    exact Nat.ne_of_gt (Nat.add_pos_left (Nat.pos_of_ne_zero h) n)
  · intro psi h; exact h
  · intro psi h e he; exact h e he
  · intro psi h e he; exact h e he

theorem addNode_admissible (x : Nat) :
    admissible_operator (addNode x) := by
  refine ⟨deterministic_all _, replayable_all _, traceable_all _, ?_, ?_, ?_, ?_, ?_⟩
  · intro psi h; exact h
  · intro psi h; exact h
  · intro psi h; exact h
  · intro psi h e he
    have hr := h e he
    exact ⟨List.mem_cons_of_mem x hr.1, List.mem_cons_of_mem x hr.2⟩
  · intro psi h e he; exact h e he

theorem wipeNs_not_namespace_preserving : ¬ namespace_preserving wipeNs := by
  intro h
  have : namespace_valid (wipeNs initial) := h initial (by simp [namespace_valid, initial])
  simp [wipeNs, namespace_valid, initial] at this

theorem wipeNs_breaks_omega : Omega initial ∧ ¬ Omega (wipeNs initial) := by
  constructor
  · exact initial_omega
  · intro h; exact h.ns rfl

theorem t0_maximal_operational_kernel
    (O : Operator) (hO : admissible_operator O) (psi : State) (hpsi : Omega psi) :
    Omega (O psi) ∧
    Omega (iterate O 3 psi) ∧
    namespace_preserving O ∧ version_preserving O ∧ provenance_preserving O ∧
    relationship_preserving O ∧ acyclicity_preserving O ∧
    D_coord (O psi) = 0 :=
  ⟨admissibility_closure psi hpsi O hO,
   admissibility_closure psi hpsi (iterate O 3) (iterate_admissible O hO 3),
   hO.2.2.2.1, hO.2.2.2.2.1, hO.2.2.2.2.2.1,
   hO.2.2.2.2.2.2.1, hO.2.2.2.2.2.2.2,
   defect_zero_of_admissible psi hpsi O hO⟩

end Chronofold.ConstitutionalKernelT0
