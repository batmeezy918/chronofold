# AGENTS.md — Constitutional Deterministic Build Protocol (v1.0)

## Mission

Construct the project as a strictly deterministic, fully replayable, machine-verifiable sequence of phases.

The repository SHALL NEVER advance to the next phase until the current phase has been fully executed, validated, and independently replay-verified.

Primary goals:

- Deterministic execution at every step
- Fully replayable build history
- Explicit, auditable state transitions
- Zero hidden assumptions or implicit behavior
- Complete traceability of all changes
- Full rollback capability at every phase boundary
- Strict idempotent execution (no side effects on re-run)

---

## Constitutional Rules

### Rule 1 — Single Source of Truth

All generated artifacts MUST originate exclusively from existing repository sources.

The system MUST NOT infer, assume, or hallucinate missing architecture.

If any requirement, dependency, or behavior is ambiguous:

STOP IMMEDIATELY.

- Record the ambiguity explicitly
- Identify impacted components
- Propose clarification questions
- Await resolution before proceeding

No guessing is permitted under any circumstance.

---

### Rule 2 — Deterministic Generation

Every generation step MUST satisfy strict functional determinism:

same input state

- same repository snapshot
- same toolchain version
  = identical output artifacts

Forbidden behaviors:

- Random number generation unless explicitly seeded and recorded
- Timestamp-dependent logic unless explicitly required and frozen
- Non-deterministic iteration ordering (e.g., unordered maps, filesystem scans)
- Environment-dependent branching without explicit capture

All ordering MUST be normalized and stable (lexicographic or explicitly defined ordering rules).

---

### Rule 3 — Replayability

Every phase MUST be fully re-executable from scratch.

Re-running Phase N under identical conditions MUST produce:

- Identical file contents
- Identical directory structure
- Identical logs
- Identical test results

If ANY deviation is detected:

FAIL the phase immediately.

Required failure output:

- Exact diff of all changed artifacts
- Root cause hypothesis (if determinable)
- Reproduction steps
- Blocking issue classification

No progression is allowed until resolved.

---

### Rule 4 — Constitutional Validation

Each phase MUST emit a complete verification bundle containing:

- Input state snapshot (files, configs, dependencies)
- Output artifacts list
- File-level diff summary
- Dependency graph before/after
- All commands executed (fully logged)
- Test suite execution results (raw + summarized)
- Determinism verification report
- Replay verification report
- Explicit list of assumptions (must be empty if possible)
- Rollback procedure (step-by-step restoration path)

---

### Rule 5 — Build Order (Strict Sequential Execution)

Phases MUST be executed in strict order. No skipping. No merging.

---

## Phase 0 — Repository Intelligence & Mapping

- Full repository scan
- File inventory (recursive, deterministic ordering)
- Dependency graph extraction
- Module boundary identification
- Architecture inference map (observational only, no modification)
- Risk analysis (technical debt, circular dependencies, missing modules)
- External dependency inventory
- Environment capture (toolchain, runtime versions)

STOP.

---

## Phase 1 — Structural Normalization

- Directory structure normalization (deterministic ordering rules)
- File naming standardization
- Removal or isolation of dead code (flagged, not deleted unless approved)
- Import path normalization
- Dependency validation and reconciliation
- Circular dependency detection and reporting
- Baseline lint pass (non-fixing mode first, then fixing if approved)

STOP.

---

## Phase 2 — Core Architecture Synthesis

- Define or validate core interfaces
- Establish domain models (strict schema-first)
- Configuration schema definition (typed, explicit)
- Constants centralization
- Dependency inversion enforcement
- Architectural boundary enforcement (layer rules)
- Contract definitions between modules

STOP.

---

## Phase 3 — Incremental Implementation (Strict Unit Execution)

For EACH component:

1. Generate implementation
2. Static analysis (lint/typecheck)
3. Compile/build verification
4. Unit test execution
5. Determinism check (re-run test suite)
6. Failure resolution loop (bounded, explicit iterations)
7. Final verification pass
8. Commit snapshot (logical, not necessarily VCS commit)

Only after full success:

→ proceed to next component

---

## Phase 4 — System Integration

- Wire all components together
- Validate interface contracts
- Run integration test suite
- Detect and resolve contract mismatches
- Verify data flow determinism across modules
- Ensure no hidden coupling exists
- Re-run full integration suite for stability confirmation

STOP.

---

## Phase 5 — Runtime Validation

- Execute full system runtime
- Capture full execution trace
- Validate outputs against expected invariants
- Measure reproducibility across multiple runs
- Detect timing, ordering, or state drift
- Generate runtime determinism report

STOP.

---

## Phase 6 — Optimization (Strictly Post-Correctness)

ONLY execute if and only if:

- All previous phases are fully passing
- Determinism is proven

Rules:

- No behavioral changes allowed
- No interface changes allowed
- Only performance improvements permitted
- Must include before/after benchmarks
- Must prove no regression in correctness or determinism

---

## Phase 7 — Deployment Packaging

- Build release artifacts
- Version all outputs deterministically
- Generate reproducible build manifest
- Validate artifact integrity (hash-based verification)
- Simulate deployment in isolated environment
- Produce deployment reproducibility report

STOP.

---

## Deterministic Replay Protocol

Every phase MUST support full replay execution:

Step 1: Execute phase
Step 2: Record full state snapshot
Step 3: Reset environment to snapshot
Step 4: Re-execute phase
Step 5: Compare outputs at byte level

If ANY mismatch occurs:

- FAIL immediately
- Produce structured diff:
  - file-level
  - line-level
  - token-level (if applicable)
- Identify nondeterministic source
- Block progression

---

## Safety Gates (Hard Constraints)

The system MUST NEVER:

- Delete code without explicit justification and logging
- Modify public interfaces without architectural approval
- Introduce new dependencies without documented rationale
- Override failing tests without root-cause resolution
- Skip validation steps
- Proceed past failed determinism checks
- Assume missing requirements

---

## Required Deliverables Per Phase

Each phase MUST produce a structured report containing:

1. Phase summary (deterministic, factual)
2. File-level change log (before/after)
3. Dependency graph delta
4. Commands executed (fully enumerated)
5. Test suite results (raw + aggregated)
6. Determinism verification report
7. Replay verification report
8. Risk register (new + existing)
9. Open assumptions (must be empty or explicitly justified)
10. Next-phase readiness assessment

---

## Completion Criteria (Strict Gate)

A phase is ONLY considered COMPLETE if ALL conditions are met:

- Build succeeds without warnings (or warnings explicitly accepted)
- All tests pass
- Deterministic replay passes byte-for-byte
- No unresolved errors or ambiguities remain
- No hidden state or undocumented behavior exists
- Repository is in a clean, consistent state

If ANY condition fails:

STOP IMMEDIATELY.

- Provide failure classification
- Provide exact reproduction steps
- Provide minimal corrective action plan
- Await explicit resolution before continuation
