# QX-TLX Quantum Corpus Lock — Full Experimental / Theorem Dossier

**Date:** 2026-09-28
**Corpus:** QX-TLX / AGD / QAE-QBE quantum structural program
**Primary formal repository:** `batmeezy918/chronofold`
**Lock status:** `FROZEN-WITH-OPEN-FORMAL-GATES`
**Evidence rule:** `ClaimStrength <= EvidenceStrength`

## 0. Executive lock statement

This dossier freezes the research state reached through the quantum quotient, inversion, BKM-curvature, CMI, perturbation, and adversarial-control experiments. It distinguishes exact mathematics, numerical observations, formally machine-checked AGD substrate, failed conjectures, and remaining proof obligations.

The central new result is an exact entropy-Hessian decomposition for the CMI trajectory under a unitary generated on `AB`. The previously proposed identification `I''(0) = Gamma_ABC(H) - Gamma_AB(H)` is **not a general theorem**. The correct bridge contains both a BKM tangent term and a reduced-state acceleration term.

## 1. Corpus progression

### Stage A — AGD quotient substrate

The formal AGD layer established the abstract pattern: an equivalence relation preserved by controlled transitions induces well-defined quotient dynamics and a commutation/bisimulation law. The current Mathlib-backed T1 theorem is present in `VERIFIED_THEOREMS/T1_AGD_CONTROLLED_BISIMULATION.lean`.

Canonical law:

`pi ∘ T_a = Tbar_a ∘ pi`

This layer is a logical substrate, not evidence that an arbitrary empirical relation is valid. The relation must satisfy the Lean hypotheses first.

### Stage B — QAE/QBE quantum reduction program

The quantum program transferred the quotient methodology to finite-dimensional density matrices, observables, dynamics, and structural equivalence. The general objective became: construct reductions whose semantics can be checked independently of their computational performance.

### Stage C — Spectral inversion response

For positive invertible `H`, define `S(H)=H^{-1}` and

`F_t(rho,H)=Tr[rho(exp(-tH)-exp(-tH^{-1}))]`.

Exact algebra gives:

`S(S(H))=H`

`F_t(rho,H^{-1})=-F_t(rho,H)`

and, for the normalized magnitude response,

`D_t(rho,H^{-1})=D_t(rho,H)`.

These are identities, not empirical discoveries. The numerical suite reproduced them to approximately machine precision across dimensions 2,3,4,6 and multiple `t` values.

### Stage D — BKM curvature channel

For a faithful density operator `sigma` and traceless Hermitian tangent `X`, the BKM quadratic form is

`Gamma_BKM(sigma;X)=Tr[X D(log)_sigma[X]]`.

The suite tested nonnegativity and the commuting/noncommuting boundary. The commuting constructions gave zero curvature; noncommuting constructions gave positive observed curvature.

The distinction is important: BKM curvature measures the Hessian/tangent response of information geometry. It is not itself the entire second derivative of an arbitrary reduced-state entropy trajectory.

### Stage E — CMI trajectory experiment

Let `rho_ABC(t)=U_t rho_ABC U_t^dagger`, with `U_t=exp(-itH_AB)` and `H_AB` acting only on `AB`. Let `sigma_BC(t)=Tr_A rho_ABC(t)`.

Because the unitary is local to `AB`, the entropies `S(ABC)`, `S(AB)`, and `S(B)` are constant. Therefore

`I(A:C|B)''(0)=S(sigma_BC(t))''|_{t=0}`.

Finite-difference experiments evaluated the actual CMI trajectory for multiple step sizes and dimensions. One family produced positive second derivative near `0.245`; another produced negative second derivative near `-0.704`. This directly falsified any blanket sign claim for `I''(0)` along this class of trajectories.

### Stage F — Failed bridge hypothesis

The candidate relation

`I''(0) = Gamma_ABC(H) - Gamma_AB(H)`

was not accepted as a general theorem. The numerical behavior and exact differentiation identify a missing second-order reduced-state term.

### Stage G — Missing bridge derivation

For

`X = dot(sigma_BC)(0) = -i Tr_A[H_AB,rho_ABC]`

and

`Y = ddot(sigma_BC)(0) = -Tr_A[H_AB,[H_AB,rho_ABC]]`,

entropy differentiation gives the exact decomposition

`I''(0) = -Gamma_BKM(sigma_BC;X) - Tr[Y log(sigma_BC)]`.

Equivalently define

`A_red = -Tr[Y log(sigma_BC)]`.

Then

`I''(0) = -Gamma_BKM + A_red`.

Therefore the exact zero-residual bridge identity is

`R_bridge = I''(0) + Gamma_BKM + Tr[Y log(sigma_BC)] = 0`.

This is the current central theorem candidate for machine formalization.

## 2. Definitive numerical suite record

Run metadata supplied from the proof-Debian environment:

- Python 3.13.5
- NumPy 2.2.4
- SciPy 1.15.3
- Linux 6.17.0 PRoot-Distro aarch64 / glibc 2.41
- Seed: 20260928
- Source SHA256: `5115f920bce2c50cc7fda81f0de640ea6159bffe7fd444bed310908d464dc0ca`
- Runtime: 0.227 s
- Total tests: 193
- PASS: 104
- OBSERVED: 80
- FAIL: 4
- FAIL_CONTROL: 2
- PASS_REJECTED: 3

The suite itself correctly reported: `OBSERVED != PROVEN`; numerical PASS is not a Lean/kernel proof; CMI-BKM relations were tested rather than assumed.

## 3. What the 193-run suite established

### 3.1 Exact inversion algebra

`S(S(H))=H` passed at errors approximately `2.7e-16` to `1.8e-14` for dimensions 2,3,4,6 under a `1e-8` numerical tolerance.

Interpretation: numerical implementation is consistent with involutive inversion. The theorem itself is exact by algebra.

### 3.2 QSI inversion-odd response

`F_t(rho,H^-1)=-F_t(rho,H)` passed across n=2,3,4,6 and t in `{0.05,0.1,0.25,0.5,1.0}`, with observed errors at or below approximately `2.2e-16`.

Interpretation: the proposed QSI observable has exact inversion oddness; the run validates implementation, not novelty.

### 3.3 Normalized inversion-even response

`D_t(rho,H^-1)=D_t(rho,H)` passed across the same dimensions and times, with errors at or below approximately `2.2e-16`.

Interpretation: the absolute normalized response is inversion invariant.

### 3.4 Commuting sector

The construction verified `[H,rho]=0` and `Gamma_rho(H)=0` in the commuting cases. Nevertheless the inversion response remained nonzero, with examples including `|F|≈7.00e-2`, `1.31e-1`, `2.66e-1`, and `4.33e-1` as `t` increased in n=2.

Interpretation: information-geometric curvature and inversion spectral asymmetry are independent channels. `Gamma=0` does not imply `F=0`.

### 3.5 Noncommuting sector

Observed examples had positive curvature with nonzero commutator norm, including approximately `Gamma=3.37` for n=2, `30.49` for n=3, and `55.53` for n=4.

Interpretation: the tested constructions exhibit the expected noncommutative curvature response. The universal implication should be treated as a theorem only after formal hypotheses are encoded.

### 3.6 Perturbation channel

Generic perturbations produced nonzero first and second responses. First-order-null searches returned small but nonzero residuals (`|R1|≈0.0093,0.0087,0.0049` for n=2,3,4), so the run did **not** establish a true first-order-null/second-order-only theorem.

Interpretation: second-order sensitivity is a valid experimental direction, but the specific first-order-null claim remains OPEN.

### 3.7 CMI channel

Actual tripartite CMI second derivatives were observed to converge under decreasing finite-difference step. For `(2,2,2)`, the values approached approximately `0.244926`; for `(2,2,3)`, values approached approximately `-0.7046`.

Interpretation: CMI itself remains nonnegative, but its trajectory second derivative is not sign-definite in general. This observation is decisive against promoting `I''>=0` or `I''<=0` as a universal theorem.

## 4. The exact current theorem stack

### T0 — Inversion involution

For positive invertible `H`:

`S^2(H)=H`.

Status: **THEOREM / exact algebra**.

### T1 — QSI inversion oddness

`F_t(rho,S(H))=-F_t(rho,H)`.

Status: **THEOREM / exact algebra**.

### T2 — Normalized inversion invariance

`D_t(rho,S(H))=D_t(rho,H)` when defined.

Status: **THEOREM / exact algebra**.

### T3 — BKM positivity

`Gamma_BKM(sigma;X)>=0` for the faithful-state tangent form.

Status: **ESTABLISHED mathematical property; formalization target remains**.

### T4 — Reduced tangent

`X=-i Tr_A[H_AB,rho_ABC]`.

Status: **THEOREM / direct differentiation**.

### T5 — Reduced acceleration

`Y=-Tr_A[H_AB,[H_AB,rho_ABC]]`.

Status: **THEOREM / direct differentiation**.

### T6 — CMI/BKM bridge

`I''(0)=-Gamma_BKM(sigma_BC;X)-Tr[Y log(sigma_BC)]`.

Status: **DERIVED THEOREM; numerical validation required; Lean/kernel certification OPEN**.

### T7 — Zero-residual bridge invariant

`I''(0)+Gamma_BKM(sigma_BC;X)+Tr[Y log(sigma_BC)]=0`.

Status: **DERIVED EXACT IDENTITY; primary next formal proof gate**.

### T8 — Restricted sign theorem

If `Tr[Y log(sigma_BC)]=0`, then `I''(0)=-Gamma_BKM<=0`.

Status: **DERIVED CONDITIONAL THEOREM**.

### T9 — Previous CMI bridge

`I''=Gamma_ABC(H)-Gamma_AB(H)`.

Status: **REJECTED AS A GENERAL THEOREM**.

## 5. Three-way structural system

The frozen system contains three distinct channels:

1. **Spectral inversion:** `H -> H^-1` and QSI response.
2. **Information geometry:** BKM curvature of the reduced tangent.
3. **Reduced dynamics:** CMI/entropy acceleration under partial trace.

The correct composition is not a scalar identification. It is an operator chain:

`rho --R--> X --Xi--> Gamma_BKM`

and independently

`rho --R2--> Y --log-coupling--> A_red`.

The CMI curvature is their signed sum:

`I'' = -Xi(R(rho)) + A_red`.

## 6. Operator-algebra representation

Let proof state `psi=(rho,H)`.

`O_S psi = (rho,H^-1)`.

`O_R psi = -i Tr_A(ad_H(rho))`.

`O_R2 psi = -Tr_A(ad_H^2(rho))`.

`O_Xi(sigma,X)=Tr[X D(log)_sigma[X]]`.

`O_A(sigma,Y)=-Tr[Y log sigma]`.

Then

`I'' = -O_Xi(O_R psi) + O_A(O_R2 psi)`.

The complete three-way measurement is

`O_3W = O_S ⊕ O_Xi ⊕ O_CMI`.

The bridge residual is

`R_bridge(psi)=I''+O_Xi(O_R psi)-O_A(O_R2 psi)=0`.

## 7. Failed / quarantined claims preserved in the lock

- The RSA modular finite-difference script does not establish a quantum Fisher-curvature theorem or deterministic modular inversion merely by naming variables that way.
- The first-order-null perturbation search did not reach its stated tolerance and remains candidate evidence.
- Numerical CMI-BKM agreement is not a Lean proof.
- The previous `Gamma_ABC-Gamma_AB` CMI formula is not accepted as general.
- No physical quantum-hardware claim follows from these finite-dimensional numerical experiments.
- No computational speedup claim follows from the quantum mathematical identities.

## 8. Proof scaffold / next formal gate

The next Lean file should encode finite-dimensional matrices/density operators, partial trace, unitary evolution, entropy differentiation assumptions, and the BKM derivative operator. The primary theorem target is:

`theorem cmi_bkm_bridge :
  I_second + bkm_curvature sigma X + trace Y (log sigma) = 0`

under explicit differentiability, faithfulness, Hermiticity, trace-one, and local-unitary hypotheses.

The proof should be decomposed into:

1. unitary invariance of `S(ABC)`;
2. local-unitary invariance of `S(AB)`;
3. invariance of `S(B)`;
4. CMI reduction to `S(BC)` along this trajectory;
5. first derivative of entropy;
6. second derivative of entropy;
7. identification of the BKM Hessian;
8. substitution of reduced first and second derivatives;
9. exact residual closure.

## 9. Corpus lock semantics

`FROZEN` means the claims, definitions, evidence classifications, failures, and theorem boundaries above are the canonical research state as of 2026-09-28. New evidence must append a new revision rather than silently changing historical classifications.

A claim may move upward only when its evidence class is independently strengthened. Numerical PASS never silently becomes THEOREM. A theorem may be strengthened only by an explicit formal proof artifact or a complete mathematical derivation whose assumptions are recorded.

## 10. Source anchors

- Primary formal substrate: `batmeezy918/chronofold`.
- Current AGD controlled quotient/bisimulation kernel: `VERIFIED_THEOREMS/T1_AGD_CONTROLLED_BISIMULATION.lean`.
- Current numerical suite source hash: `5115f920bce2c50cc7fda81f0de640ea6159bffe7fd444bed310908d464dc0ca`.
- Current numerical result artifact: `QX_TLX_QUANTUM_RESULTS.json` from the 2026-09-28 proof-Debian run.
- Supplied run summary: 193 total; 104 PASS; 80 OBSERVED; 4 FAIL; 2 FAIL_CONTROL; 3 PASS_REJECTED.

## 11. Final locked conclusion

The research state is not that a single universal quantum curvature scalar has been discovered. The stronger defensible conclusion is that the experiments exposed a structural separation between spectral inversion response, BKM tangent curvature, and reduced-state dynamical acceleration, and that the CMI second derivative is exactly decomposed by the latter two channels.

The highest-value remaining proof obligation is therefore not another empirical identity. It is formal certification of the zero-residual CMI/BKM bridge under explicit finite-dimensional hypotheses.

**LOCK:** `QX-TLX-QUANTUM-CORPUS-2026-09-28`
