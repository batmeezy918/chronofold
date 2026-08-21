# O∞ Constitutional Closure: Proof Graph

This document visualizes and maps the dependencies of formal proofs, lemmas, structures, and definitions in the ChronoFold Lean 4 specification.

---

## 1. Minimal Admissible Quotient ($Q^*$) Proof Hierarchy

The formalization in `Verify.lean` defines the core quotient properties of the AGD framework.

```
State (α) ──> Omega (α) ──> Covariant (α) ──> Operator (α)
 │
 ├──> AGDEquiv (Equivalence relation on state parameters)
 │     │
 │     ├──> AGDEquiv.refl (Reflexivity proof)
 │     ├──> AGDEquiv.symm (Symmetry proof)
 │     └──> AGDEquiv.trans (Transitivity proof)
 │           │
 │           └──> agdSetoid (Setoid instance over State)
 │                 │
 │                 └──> QStar (Quotient type definition)
 │                       │
 │                       ├──> pi (Canonical projection function)
 │                       ├──> OmegaBar (Quotient-lifted Omega)
 │                       └──> CBar (Quotient-lifted Covariant)
 ```

### Theorem-Level Dependencies

* **`TBar` (Quotient Operator Lifter)**:
  - *Depends on*: `pi`, `Admissible`, `Quotient.lift`, `Quotient.sound`.
  - *Derived Lemmas*: `TBar_sound` (computational behavior of `TBar` over `pi`), `descends` (existence of quotient operators).

* **`uniqueMorph` and `uniqueMorph_unique` (Universal Initiality)**:
  - *Depends on*: `PreservingQuotient` structure, `Quotient.lift`, `Quotient.ind`, `funext`.
  - *Role*: Establishes that $Q^*$ is the initial object in the category of observation-preserving quotients.

* **`admission_iff_descends` (Admissibility Identity equivalence)**:
  - *Depends on*: `TBar_sound`, `Quotient.exact`, `Quotient.sound`, `Quotient.ind`.
  - *Role*: Proves that an operator is admissible if and only if it descends to the identity on $Q^*$.

---

## 2. ChronoFold Operator Bounds Hierarchy

The definitions in `ChronoFold/Auto.lean` outline the mathematics of the $\Omega$-operator.

```
rho_step (x, c, n)
 │
 ├──> omega (x, n) ──> omega_step (x, c, n)
       │
       ├──> omega_divides_n  [Nat.gcd_dvd_right]
       ├──> omega_nonneg     [Nat.zero_le]
       └──> omega_le_n       [Nat.gcd_le_right, (0 < n)]
```

### Module Boundary Cross-References

```
[ChronoFold/Auto.lean]                         [Verify.lean]
      omega (x, n)                                 State (α)
           │                                          │
 (Algebraic state probe) ───[To be unified]───> (Observable coordinate)
```
- Currently, the concrete natural number $\Omega$-operator mathematics in `Auto.lean` acts as an instantiation candidate for the general coordinate `State α → Nat` functions defined in `Verify.lean`.
- Unification between these layers is a planned future operator transformation.
