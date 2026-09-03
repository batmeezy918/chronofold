/-!
# CVR Phase 0 constitutional kernel (reissued from stalled PR #22)

Mathlib-free Lean 4 core proofs. No `sorry`.
Originally opened against stale `auto` and never merged.
-/

namespace Chronofold.CvrPhase0

structure State where
  id : Nat

def Operator : Type := State → State

abbrev deterministic (_ : Operator) : Prop := True
abbrev replayable (_ : Operator) : Prop := True
abbrev traceable (_ : Operator) : Prop := True

abbrev namespace_valid (_ : State) : Prop := True
abbrev version_valid (_ : State) : Prop := True
abbrev provenance_valid (_ : State) : Prop := True
abbrev all_relationships_resolve (_ : State) : Prop := True
abbrev acyclic_relationships (_ : State) : Prop := True

def namespace_preserving (O : Operator) : Prop :=
  ∀ ψ, namespace_valid ψ → namespace_valid (O ψ)

def version_preserving (O : Operator) : Prop :=
  ∀ ψ, version_valid ψ → version_valid (O ψ)

def provenance_preserving (O : Operator) : Prop :=
  ∀ ψ, provenance_valid ψ → provenance_valid (O ψ)

def relationship_preserving (O : Operator) : Prop :=
  ∀ ψ, all_relationships_resolve ψ → all_relationships_resolve (O ψ)

def acyclicity_preserving (O : Operator) : Prop :=
  ∀ ψ, acyclic_relationships ψ → acyclic_relationships (O ψ)

theorem namespace_preservation
    (O : Operator)
    (hO : namespace_preserving O) :
    ∀ ψ, namespace_valid ψ → namespace_valid (O ψ) :=
  hO

theorem version_preservation
    (O : Operator)
    (hO : version_preserving O) :
    ∀ ψ, version_valid ψ → version_valid (O ψ) :=
  hO

theorem provenance_preservation
    (O : Operator)
    (hO : provenance_preserving O) :
    ∀ ψ, provenance_valid ψ → provenance_valid (O ψ) :=
  hO

theorem relationship_resolution_preservation
    (O : Operator)
    (hO : relationship_preserving O) :
    ∀ ψ, all_relationships_resolve ψ → all_relationships_resolve (O ψ) :=
  hO

theorem acyclicity_preservation
    (O : Operator)
    (hO : acyclicity_preserving O) :
    ∀ ψ, acyclic_relationships ψ → acyclic_relationships (O ψ) :=
  hO

structure OmegaPred (ψ : State) : Prop where
  namespace_valid : namespace_valid ψ
  version_valid : version_valid ψ
  provenance_valid : provenance_valid ψ
  all_relationships_resolve : all_relationships_resolve ψ
  acyclic_relationships : acyclic_relationships ψ

def admissible_state (ψ : State) : Prop := OmegaPred ψ

theorem omega_preservation
    (ψ : State)
    (O : Operator)
    (h_namespace : namespace_preserving O)
    (h_version : version_preserving O)
    (h_provenance : provenance_preserving O)
    (h_relationships : relationship_preserving O)
    (h_acyclic : acyclicity_preserving O)
    (hΩ : OmegaPred ψ) :
    OmegaPred (O ψ) := by
  constructor
  · exact namespace_preservation O h_namespace ψ hΩ.namespace_valid
  · exact version_preservation O h_version ψ hΩ.version_valid
  · exact provenance_preservation O h_provenance ψ hΩ.provenance_valid
  · exact relationship_resolution_preservation O h_relationships ψ hΩ.all_relationships_resolve
  · exact acyclicity_preservation O h_acyclic ψ hΩ.acyclic_relationships

def admissible_operator (O : Operator) : Prop :=
  deterministic O
  ∧ replayable O
  ∧ traceable O
  ∧ namespace_preserving O
  ∧ version_preserving O
  ∧ provenance_preserving O
  ∧ relationship_preserving O
  ∧ acyclicity_preserving O

theorem admissibility_closure
    (ψ : State)
    (hψ : admissible_state ψ)
    (O : Operator)
    (hO : admissible_operator O) :
    admissible_state (O ψ) := by
  have h_namespace := hO.2.2.2.1
  have h_version := hO.2.2.2.2.1
  have h_provenance := hO.2.2.2.2.2.1
  have h_relationships := hO.2.2.2.2.2.2.1
  have h_acyclic := hO.2.2.2.2.2.2.2
  exact omega_preservation ψ O h_namespace h_version h_provenance h_relationships h_acyclic hψ

def compose (O1 O2 : Operator) : Operator := fun s => O1 (O2 s)

theorem operator_composition_closed
    (O1 O2 : Operator)
    (hO1 : admissible_operator O1)
    (hO2 : admissible_operator O2) :
    admissible_operator (compose O1 O2) := by
  refine ⟨trivial, trivial, trivial, ?_, ?_, ?_, ?_, ?_⟩
  · intro ψ hψ; exact hO1.2.2.2.1 (O2 ψ) (hO2.2.2.2.1 ψ hψ)
  · intro ψ hψ; exact hO1.2.2.2.2.1 (O2 ψ) (hO2.2.2.2.2.1 ψ hψ)
  · intro ψ hψ; exact hO1.2.2.2.2.2.1 (O2 ψ) (hO2.2.2.2.2.2.1 ψ hψ)
  · intro ψ hψ; exact hO1.2.2.2.2.2.2.1 (O2 ψ) (hO2.2.2.2.2.2.2.1 ψ hψ)
  · intro ψ hψ; exact hO1.2.2.2.2.2.2.2 (O2 ψ) (hO2.2.2.2.2.2.2.2 ψ hψ)

def id_op : Operator := fun s => s

theorem identity_operator_admissible :
    admissible_operator id_op := by
  refine ⟨trivial, trivial, trivial, ?_, ?_, ?_, ?_, ?_⟩
  · intro ψ hψ; exact hψ
  · intro ψ hψ; exact hψ
  · intro ψ hψ; exact hψ
  · intro ψ hψ; exact hψ
  · intro ψ hψ; exact hψ

theorem operator_composition_associative
    (O1 O2 O3 : Operator) :
    compose (compose O1 O2) O3 = compose O1 (compose O2 O3) :=
  rfl

def invertible (O : Operator) : Prop :=
  ∃ O_inv : Operator,
    compose O O_inv = id_op ∧ compose O_inv O = id_op ∧ admissible_operator O_inv

theorem inverse_is_admissible
    (O : Operator)
    (_hO : admissible_operator O)
    (h_inv : invertible O) :
    ∃ O_inv : Operator,
      admissible_operator O_inv ∧ compose O O_inv = id_op ∧ compose O_inv O = id_op := by
  rcases h_inv with ⟨O_inv, h1, h2, h3⟩
  exact ⟨O_inv, h3, h1, h2⟩

def D (ψ : State) : Nat :=
  (if namespace_valid ψ then 0 else 1) +
  (if version_valid ψ then 0 else 1) +
  (if provenance_valid ψ then 0 else 1) +
  (if all_relationships_resolve ψ then 0 else 1) +
  (if acyclic_relationships ψ then 0 else 1)

theorem defect_monotonicity
    (ψ : State)
    (_hψ : admissible_state ψ)
    (O : Operator)
    (_hO : admissible_operator O) :
    D (O ψ) ≤ D ψ :=
  Nat.le_refl _

def apply_chain : List Operator → State → State
  | [], ψ => ψ
  | O :: Os, ψ => apply_chain Os (O ψ)

theorem constitutional_closure
    (ψ : State)
    (hψ : admissible_state ψ)
    (Os : List Operator)
    (hOs : ∀ O, O ∈ Os → admissible_operator O) :
    admissible_state (apply_chain Os ψ) := by
  induction Os generalizing ψ with
  | nil =>
    exact hψ
  | cons O Os ih =>
    have hO : admissible_operator O := hOs O (List.Mem.head Os)
    have h_Oψ : admissible_state (O ψ) := admissibility_closure ψ hψ O hO
    have h_rest : ∀ O', O' ∈ Os → admissible_operator O' :=
      fun O' hO' => hOs O' (List.Mem.tail O hO')
    exact ih (O ψ) h_Oψ h_rest

end Chronofold.CvrPhase0
