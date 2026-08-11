# ChronoFold COCO Head-to-Head Benchmark

This benchmark compares the deterministic S6 path against a pinned, independently maintained CMA-ES implementation on the official COCO `bbob` suite.

## Claims measured

The benchmark does **not** assume that S6 wins. It records:

- COCO target-hit runtime (function evaluations) and final best value;
- S6 exact repeatability under identical provenance;
- CMA-ES fixed-seed repeatability;
- per-problem S6-only wins, CMA-only wins, ties, and both-fail cases;
- target-hit evaluation ratios where both algorithms succeed;
- supplementary S6 constitutional/projection diagnostics.

`cma==4.4.4` is treated as a strong contemporary CMA-ES reference implementation, **not** as a claim of universal state-of-the-art. The official COCO archive is used separately for established archived BIPOP-CMA-ES comparisons.

## Suite

- COCO `bbob`
- dimension 10
- all 24 functions and 15 instances = 360 problems
- maximum budget: 1000 objective evaluations/problem
- same problem, budget, and observer protocol for both algorithms

COCO's own performance methodology treats function evaluations to target as the central runtime measure. Final objective values are retained as a fixed-budget secondary measure.

## Novelty/failure classification

A problem is classified from the observed data, not from a prior hypothesis:

- `S6_ONLY`: S6 hits the final COCO target within the budget and CMA-ES does not.
- `CMA_ONLY`: CMA-ES hits it and S6 does not.
- `BOTH`: both hit it; runtime ratio is reported.
- `NEITHER`: neither hits it; final best values are reported.

Additional S6 diagnostics are explicitly labeled supplementary and are not substituted for COCO's official performance measures.
