# CLAIM_MATRIX

| Claim ID | Formal / Empirical Claim Statement | Constitutional Classification | Evidence Source / Proof Witness |
|---|---|---|---|
| C-001 | Minimal Admissible Quotient ($Q^*$) exists and quotient operation descends cleanly for admissible operators | FORMALLY_PROVED | `Verify.lean` (`TBar_sound`, `descends`) |
| C-002 | $Q^*$ satisfies universal initiality among invariant-preserving quotients | FORMALLY_PROVED | `Verify.lean` (`uniqueMorph_unique`) |
| C-003 | An operator is admissible if and only if its descended map on $Q^*$ behaves as identity | FORMALLY_PROVED | `Verify.lean` (`admission_iff_descends`) |
| C-004 | Replay of a sequence of admissible operators preserves system invariants | FORMALLY_PROVED | `Verify.lean` (`replay_preserves_invariants`) |
| C-005 | Theorem intake pipeline processes, validates, compiles, and issues deterministic receipts | EMPIRICALLY_VERIFIED | `scripts/process_inbox.sh` & `theorem_receipts/*.json` |
| C-006 | Optimization pipeline exhibits empirical convergence on standard benchmarks | EMPIRICALLY_VERIFIED | `real_results.json` & benchmark suite |
