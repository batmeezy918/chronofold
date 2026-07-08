# File Transformation Logic: From Source to Proven Artifact

This document formalizes the mapping of Lean 4 source modules to the certified "Proven Agd Theorums" artifact store.

## Transformation Map

| Source File | Theorem (Internal) | Target Artifact (Proven) |
|-------------|--------------------|-------------------------|
| `MeasurementCertificate.lean` | `jitter_close_reflexive` | `THM_000101__jitter_close_reflexive.lean` |
| `MeasurementCertificate.lean` | `jitter_close_symmetric` | `THM_000102__jitter_close_symmetric.lean` |
| `MeasurementCertificate.lean` | `jitter_close_triangle` | `THM_000103__jitter_close_triangle.lean` |
| `AgdQuotient.lean` | `operator_preserves_equivalence` | `THM_000104__operator_preserves_equivalence.lean` |
| `BenchmarkCertificate.lean` | `speedup_positive` | `THM_000105__speedup_positive.lean` |
| `BenchmarkCertificate.lean` | `benchmark_claim_valid` | `THM_000106__benchmark_claim_valid.lean` |
| `AgdInformationGeometry.lean` | `agd_transport_closure` | `THM_000107__agd_transport_closure.lean` |
| `AgdInformationGeometry.lean` | `curvature_convergence` | `THM_000108__curvature_convergence.lean` |
| `AgdInformationGeometry.lean` | `agd_bisimulation` | `THM_000109__agd_bisimulation.lean` |
| `AgdInformationGeometry.lean` | `agd_flow_semigroup` | `THM_000110__agd_flow_semigroup.lean` |
| `AgdInformationGeometry.lean` | `agd_master_dynamic_closure` | `THM_000111__agd_master_dynamic_closure.lean` |
| `AgdSpectral.lean` | `AGD_Spectral_Convergence` | `THM_000112__agd_spectral_convergence.lean` |
| `AgdAdaptiveOperator.lean` | `adaptive_operator_preservation` | `THM_000201__adaptive_operator_preservation.lean` |
| `AgdRollback.lean` | `agd_failure_recovery` | `THM_000202__agd_failure_recovery.lean` |
| `AgdLearning.lean` | `learning_manifold_stability` | `THM_000203__learning_manifold_stability.lean` |
| `AgdMemoryLineage.lean` | `memory_lineage_reconstruction` | `THM_000204__memory_lineage_reconstruction.lean` |
| `AgdAutonomousClosure.lean` | `agd_autonomous_closure` | `THM_000205__agd_autonomous_closure.lean` |

## Transformation Rules

1. **Isolation**: Each theorem must be stand-alone. Definitions from the source file are duplicated into the target file to ensure zero external dependencies (except Mathlib).
2. **Metadata Injection**: Each file is prepended with `THEOREM_ID`, `TITLE`, `AUTHOR`, and `STATUS`.
3. **Naming Alignment**: Internal theorem names are lowercased (if needed) to match the `THM_######__name.lean` convention.
4. **Namespace Encapsulation**: All proven artifacts are wrapped in the `AGD` namespace to prevent collisions during global auditing.
