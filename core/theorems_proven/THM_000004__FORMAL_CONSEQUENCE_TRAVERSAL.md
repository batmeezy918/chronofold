# THM_000004 — Formal Consequence Traversal (v1.1 corrected)

**Repository:** `batmeezy918/chronofold`  
**Folder:** `core/theorems_proven`  
**Date:** 2026-09-23  
**Governing law:** claim strength never exceeds evidence strength.  
**Scope:** start-to-finish logical traversal of theorems that are actually present.  
**Non-scope:** repairing proofs, filling missing operators, or promoting narrative.

This file supersedes `FORMAL_CLOSURE_PATCH_v1` after cross-reference against Lean sources
in `chronofold`, `OIC-Core-Calculus`, and `Speedup/lean4`.

---

## 0. Patch audit (what was wrong, what stands)

| Patch claim | Verdict | Correction |
|---|---|---|
| C1 chain `AGDEquiv → Admissible → TBar_sound → …` | **Order error** | `Admissible` is a definition on operators. `AGDEquiv` is a relation on states. Neither implies the other. `TBar` requires `Admissible`, not `AGDEquiv`. |
| C1 as one operator chain including section/reconstruction | **Over-joined** | Section `σ` is not constructed in `AgdCore`/`AgdOperators`. Reconstruction lives in `AgdFecu` under an extra `Section` hypothesis. |
| C2 `π surjective → nontrivial fibre → non-injective → card drop` | **Incomplete hypotheses** | Needs finite types, a covering embed `S → State`, and an explicit nontrivial fibre. `pi` is always surjective; strict card drop is not. |
| C3 work ratio 16 | **Stands** | Exact `Nat` identity in declared model `fullWork m n k = 2*m*n*k`. Not runtime. |
| C4 `derive_sound → boundary → bidirectional_closure → …` | **Not a dependency chain** | Those OIC theorems are independent inhabitants. `bidirectional_closure` does not use `derive_sound`. |
| C5 claim/evidence separation | **Stands as policy + two Lean lemmas** | `unpublished_if_formal_missing`, `formal_work_is_not_runtime`. Not a physical theorem. |
| `admissible_iterate` previously “stubbed” | **Outdated** | Current `AgdIterate.lean` proves full `Nat` induction with zero `sorry`. |
| Global composition closed | **Correctly denied by the patch** | Remains denied. |

Elevations that survive the audit:

- `CLOSED_AGD_ADMISSIBLE_ALGEBRA` (local, sorry-free modules listed below).
- `CLOSED_FORMAL_WORK_RATIO_16` (declared arithmetic).
- `CLOSED_OIC_DIAGNOSTIC_CALCULUS` (empty-corpus diagnostic totality, external package).
- Boundaries remain first-class terminal states, not failures of the calculus.

---

## 1. Modules admitted to the closed traversal

Sorry-free production modules used as edges:

| Module | Role |
|---|---|
| `src/Chronofold/AgdCore.lean` | `State`, `Omega`, `Covariant`, `Operator`, `Admissible` |
| `src/Chronofold/AgdOperators.lean` | `AGDEquiv`, setoid, `QStar`, `pi`, `TBar`, `TBar_sound` |
| `src/Chronofold/AgdInvariants.lean` | `interchangeable_iff`, `admission_iff_TBar`, `admissible_implies_descends` |
| `src/Chronofold/AgdClosure.lean` | `admissible_compose` |
| `src/Chronofold/AgdIterate.lean` | `opIterate`, `admissible_id`, `admissible_iterate`, `TBar_iterate_sound` |
| `src/Chronofold/AgdFiniteReduction.lean` | finite card drop under extra hypotheses |
| `src/Chronofold/AgdFecu.lean` | intertwining iteration, section reconstruction, work model |
| `OIC-Core-Calculus/OICCore/Basic.lean` | external diagnostic calculus (not imported here) |

Modules **excluded** from the closed traversal because they are not sorry-free or not compiled into this package:

- `AgdBidirectional.lean` (sorry token present at last scan)
- `AgdOperationalQuotient.lean` (sorry token present at last scan)
- OIC as a Lake import of Chronofold (no `require` / no `Corpus` instance)
- Speedup PCSS empirical gates
- `core/src/lean/ChronoFold/Threadlock.lean` axiom path

If a later CI build shows those two AGD files sorry-free, they may be admitted by a new receipt. They are not admitted here.

---

## 2. Hierarchical order (foundations to consequences)

```
A. Carriers: State, Omega, Covariant, Operator
B. Admissible T := forall s, Omega(T s)=Omega s /\ C(T s)=C s
C. AGDEquiv s1 s2 := Omega s1 = Omega s2 /\ C s1 = C s2; setoid; QStar; pi
D. TBar from Admissible + Quotient.lift; TBar_sound : TBar (pi s) = pi (T s)
E. interchangeable_iff; admission_iff_TBar; admissible_implies_descends
F. admissible_id; admissible_compose; admissible_iterate; TBar_iterate_sound
G. FECU: Intertwines / SemPres / Section => iterate intertwining and reconstruction
H. fullWork m n k = 2*m*n*k; canonical 1024/256 instance ratio 16
I. pi_surjective always; strict card drop only with Fintype + cover + nontrivial fibre
J. formal_work_is_not_runtime; unpublished_if_formal_missing
```

This is the only hierarchical order justified by the sources.

---

## 3. Dependency DAG

Admissible is required by TBar, not by AGDEquiv.
AGDEquiv is required by the setoid, QStar, and pi.
TBar_sound is definitional on Quotient.lift.
admissible_compose and admissible_iterate close the operator algebra.
TBar_iterate_sound instantiates TBar_sound at T^n.
TBar_sound gives FECU.Intertwines for (T, TBar, pi).
Section sigma is NOT produced by AGD core.
fecu_len3_certified needs Intertwines /\ SemPres /\ Section.
canonical_work_closure is independent numeral arithmetic.
There is no compiled edge from Chronofold.AGD to OIC.Corpus.

---

## 4. Start-to-finish unfolding

### Step 0 — carriers (`AgdCore.lean`)
State, Omega, Covariant, Operator. No theorem yet.

### Step 1 — admissibility (`AgdCore.lean`)
Admissible Omega C T := forall s, Omega (T s) = Omega s /\ C (T s) = C s.
This is the only invariant transport rule in the AGD core.

### Step 2 — observable equivalence (`AgdOperators.lean`)
AGDEquiv.refl / symm / trans. Independent of T.

### Step 3 — quotient (`AgdOperators.lean`)
agdSetoid.r := AGDEquiv; QStar := Quotient; pi := Quotient.mk.
pi_surjective is proved in AgdFiniteReduction by Quotient.inductionOn.

### Step 4 — descent (`AgdOperators.lean`)
TBar is Quotient.lift of pi compose T. Well-definedness uses Admissible to transfer Omega/C through T, then AGDEquiv of images.

### Step 5 — one-step intertwining (`TBar_sound`)
TBar (pi s) = pi (T s) by rfl.
Admissible T => TBar well-defined => TBar_sound.
Form: pi compose T = TBar compose pi.

### Step 6 — characterizations (`AgdInvariants.lean`)
interchangeable <-> AGDEquiv by Quotient.exact / Quotient.sound.
admission_iff_TBar restates TBar_sound.
admissible_implies_descends witnesses TBar.

### Step 7 — composition (`admissible_compose`)
Omega (S (T s)) = Omega (T s) = Omega s, likewise C.
admissible_id in AgdIterate.

### Step 8 — iteration (`AgdIterate.lean`)
opIterate T 0 = id; opIterate T (n+1) = T compose opIterate T n.
admissible_iterate by induction. TBar_iterate_sound instantiates TBar_sound.
Closed: Admissible T => Admissible T^n => pi compose T^n = TBar_(T^n) compose pi.
No section is produced.

### Step 9 — FECU (`AgdFecu.lean`)
Separate namespace. No import of AgdCore.
Justified bridge: TBar_sound => FECU.Intertwines T (TBar T hT) pi.
MISSING from core: Section, SemPres (unless obs is a function of Omega/C), OCR.
Closed implications given those hypotheses:
Intertwines => fecu_execution_preservation.
Intertwines /\ SemPres => fecu_observable_preservation.
Intertwines /\ Section => reconstructed operator, reconstruction closure, pi surjective from section.
All three => fecu_len3_certified.
fecu_theorem also needs OCR.
No gap inside those implications. Gap is inhabitation of Section and OCR from AGD core.

### Step 10 — declared work ratio (`AgdFecu.lean`)
fullWork m n k := 2*m*n*k; quotientWork r s k := 2*r*s*k.
outer_factorization: fullWork (q*r) (q*s) k = q*q * quotientWork r s k.
Canonical: 1024 = 4*256, ratio 16, fullWork=2147483648, quotientWork=134217728.
Classification: CLOSED_FORMAL_WORK_RATIO_16.
formal_work_is_not_runtime: runtimeRatio 1596 100 != 16.

### Step 11 — finite reduction (`AgdFiniteReduction.lean`)
pi always surjective.
strict card drop requires Fintype S, Fintype QStar, covering embed, nontrivial fibre.
Structural cardinality, not work, not runtime.

### Step 12 — OIC external (`OICCore/Basic.lean`)
Not imported. Independent theorems, not a pipeline.
derive, authorize, reverseDerive are constantly none.
bidirectional_closure always constructs a definition-boundary.
CLOSED_DIAGNOSTIC_CALCULUS over an empty corpus. Not decidability of P.
AGDAdmissible is forall psi, True.

### Step 13 — global composition
Advertised AGD -> OIC -> ThreadLock-RCC -> Reality-Coherence -> PCSS publish is not compiled.
Justified triple: (psi_AGD_closed, psi_W16, psi_OIC_terminal) with no joining operator.

---

## 5. Transport ledger

| Stage | Invariant | Operator | Status |
|---|---|---|---|
| AGD one step | Omega, C | admissible T | PRESERVED |
| AGD compose | Omega, C | S compose T | PRESERVED |
| AGD iterate | Omega, C | T^n | PRESERVED |
| AGD descent | class [Omega,C] | TBar | PRESERVED |
| AGD iterate descent | class [Omega,C] | TBar_(T^n) | PRESERVED |
| FECU observables | obsX / obsY | T^n / Tbar^n | PRESERVED if SemPres |
| FECU reconstruction | id on Y | pi compose sigma | PRESERVED if Section |
| Work W | declared 2mnk | q-factor | TRANSFORMED by q^2 |
| Runtime | wall-clock | same | NOT ESTABLISHED |
| OIC certificate | certificate fields | phaseTransition | PRESERVED |
| AGD to OIC | Admissible | injection | NOT ESTABLISHED |
| Heat-trace / curvature | — | — | NOT APPLICABLE |

---

## 6. Closure audit

Closed paths: admissible algebra; one-step and n-step descent; interchangeable iff AGDEquiv; FECU implications from stated hypotheses; canonical work ratio 16; formal_work_is_not_runtime; OIC boundary inhabitance.

Breaks not repaired:
1. O_AGDinject
2. O_section_from_core
3. O_derive_nontrivial
4. O_authorize_nontrivial
5. O_reverseDerive
6. O_runtime_bridge
7. O_official_X
8. sorry-bearing AGD files excluded

---

## 7. Formal runtime of this traversal

R_formal = (depth_closed_AGD=8, fecu_conditional=3, work_arithmetic=1, finite_reduction=conditional, compiled_cross_edges=0, missing_operators=7, sorry_excluded=2).
No S_formal is claimed. The factor 16 is work-model arithmetic.

---

## 8. Evidence matrix

| Claim | Lean | Computational | Empirical | Status |
|---|---|---|---|
| Admissible operators closed under id/compose/iterate | Yes | N/A | N/A | CLOSED |
| pi compose T = TBar compose pi given Admissible | Yes | N/A | N/A | CLOSED |
| pi compose T^n = TBar_(T^n) compose pi | Yes | N/A | N/A | CLOSED |
| Section exists in AGD core | No | No | No | MISSING |
| W_full/W_red = 16 on canonical instance | Yes | same Nat | N/A | CLOSED_FORMAL_WORK_RATIO_16 |
| Runtime speedup 16x | No | not identified | unofficial surrogate does not support it | NOT ESTABLISHED |
| Finite card drop | Yes, conditional | N/A | N/A | CLOSED under hypotheses |
| OIC decides arbitrary P | No | derive=none | N/A | CLOSED only as diagnostic boundary |
| AGD injected into OIC | No | no lake require | N/A | MISSING |
| Publish silicon artifact | Predicate only | gates exist in Speedup | official X absent | NOT VERIFIED |

---

## 9. Maximal justified composition

O_local = TBar_iterate_sound compose admissible_iterate compose admissible_compose compose TBar_sound compose (agdSetoid / pi).
psi_AGD_closed = O_local psi_AGD.
O_work = canonical_work_closure.
psi_W16 = O_work (1024,256,1024).
O_fecu restricted to Intertwines /\ SemPres /\ Section = fecu_len3_certified.
O_OIC = bidirectional_closure square empty_corpus_always_boundary.
psi_OIC_terminal = Boundary(P).
O_total_advertised is not inhabited.
psi_final_justified = (psi_AGD_closed, psi_W16, psi_OIC_terminal) unjoined.

---

## 10. What this traversal makes possible

Because TBar_sound and admissible_iterate exist, every admissible operator has a well-defined quotient iterate.
Because canonical_work_closure exists, the declared GEMM work instance is a machine-checked numeral fact.
Because OIC bidirectional_closure exists, absence of a derivation witness is a typed object rather than an informal failure.
Because formal_work_is_not_runtime exists, the 16x work identity cannot be silently read as a 16x runtime theorem.
Nothing in this folder makes the advertised four-stage compiler a verified artifact.

---

## 11. Integrity decision

No unsupported theorem was promoted.
FORMAL_CLOSURE_PATCH_v1 is accepted after the order and hypothesis corrections in sections 0-4.
Maximum defensible elevation remains: closed local AGD admissible algebra and descent; closed declared arithmetic/work consequences; closed OIC diagnostic calculus over an empty corpus; recorded but unimplemented cross-repository transport; runtime and official-benchmark claims requiring independent evidence.
