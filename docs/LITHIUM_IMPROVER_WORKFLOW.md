# Lithium Improver Workflow: AGD Formal Verification Pipeline

This document outlines the iterative formalization and refactoring workflow utilized by Jules (the agent) to achieve zero-error, axiom-clean Lean 4 proofs for the ChronoFold AGD framework.

## Core Development Loop (The Lithium Loop)

1. **State Observation**: Read existing Lean definitions and physical benchmark data (JSON).
2. **Drafting**: Generate a formal proof structure in `src/Chronofold/`.
3. **Verification**: Run `lake build` and capture standard error.
4. **Refactoring (Error-Feedback)**:
    - **Type Mismatch**: Analyze expected vs. actual types; adjust tactic application.
    - **Unification Failure**: Explicitly provide implicit arguments or use `rw` / `simp` with precise lemmas.
    - **Vacuous Proof Detection**: Replace `trivial` or `exists True` with substantive induction or calculation blocks.
5. **Isolation**: Extract the verified theorem into the `Proven Agd Theorums` directory.
6. **Validation**: Run `validate_theorem.py` to ensure compliance with the repository's deterministic audit standards.

## Functional Components

- **Measurement Layer**: Maps `ℝ^5` physical metrics to `AGDObservation`.
- **Quotient System**: Formalizes hardware-independent equivalence.
- **Spectral Dynamics**: Proves contraction-driven convergence.
- **Autonomous Closure**: Integrates adaptive selection and rollback recovery.

## Bi-Directional Propagation

- **Physical → Formal**: Benchmarks generate `agd_chronofold_results.json` which informs the constants (e.g., `ε`) in the proofs.
- **Formal → Physical**: Proven certificates (e.g., `BenchmarkCertificate`) define the validation logic for the runtime optimizer.
