# Proof Graph Report

This document defines the dependency structure of the formal theorems, lemmas, and definitions inside `Verify.lean`.

## Topological Order of Proof Nodes

```
       [State]   [Omega]   [Covariant]   [Operator]
          \         |          |             /
           \________|__________|____________/
                         |
                    [AGDEquiv]
                         |
                    [agdSetoid]
                   /     |     \
                  /      |      \
           [QStar]    [pi]   [interchangeable]
              |          |           |
           [TBar]  [TBar_sound]  [interchangeable_iff]
              |          |
          [descends] [PreservingQuotient]
                         |
                  [uniqueMorph]
                         |
               [uniqueMorph_unique]
                         |
             [admission_iff_descends]
```

## Node Reference and Dependency Table

1. **State, Omega, Covariant, Operator**
   - *Type*: Primitive structure and abbrev definitions.
   - *Dependencies*: None.
   - *Purpose*: Defines state space, system invariants $\Omega$, and laws $C$.

2. **AGDEquiv**
   - *Type*: Equivalence predicate.
   - *Dependencies*: `State`, `Omega`, `Covariant`.
   - *Purpose*: Establishes equivalence of states under invariant preservation.

3. **agdSetoid**
   - *Type*: Setoid instance.
   - *Dependencies*: `AGDEquiv`, `AGDEquiv.refl`, `AGDEquiv.symm`, `AGDEquiv.trans`.
   - *Purpose*: Packages the equivalence relation for quotient generation.

4. **QStar**
   - *Type*: Quotient Type.
   - *Dependencies*: `agdSetoid`.
   - *Purpose*: Represents the Minimal Admissible Quotient space.

5. **pi**
   - *Type*: Canonical projection mapping.
   - *Dependencies*: `QStar`.
   - *Purpose*: Map states from the physical space to the quotient space.

6. **TBar**
   - *Type*: Noncomputable operator lifting.
   - *Dependencies*: `QStar`, `pi`, `Admissible`.
   - *Purpose*: Lifts physical operators to quotient space functions.

7. **TBar_sound**
   - *Type*: Theorem.
   - *Dependencies*: `TBar`, `pi`.
   - *Purpose*: Proves the homomorphism condition $\overline{T}(\pi(s)) = \pi(T(s))$.

8. **uniqueMorph**
   - *Type*: Uniqueness lift map.
   - *Dependencies*: `PreservingQuotient`, `QStar`.
   - *Purpose*: Maps $Q^*$ to any other invariant-preserving quotient carrier.

9. **uniqueMorph_unique**
   - *Type*: Theorem.
   - *Dependencies*: `uniqueMorph`, `pi`, `PreservingQuotient`.
   - *Purpose*: Proves that $Q^*$ is universally initial (minimality of $Q^*$).

10. **admission_iff_descends**
    - *Type*: Main Closure Theorem.
    - *Dependencies*: `Admissible`, `TBar_sound`, `uniqueMorph_unique`, `interchangeable_iff`.
    - *Purpose*: Proves an operator is admissible if and only if its descended map acts as the identity on the quotient space.
