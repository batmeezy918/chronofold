# Q* Universal Property (Lean formalization)

File: `src/Chronofold/AgdUniversal.lean`

## Theorems (contentful)

| Theorem | Statement |
|---------|-----------|
| `RespectsAGD` | Map constant on AGD classes |
| `lift` / `lift_pi` | Existence of factor through `pi` |
| `lift_unique` | Uniqueness of the factor |
| **`qstar_universal`** | ∃! f̄ : Q* → β with f̄ ∘ pi = f |
| `PreservingQuotient` | Structure for any AGD-collapsing projection |
| `morphTo` | Canonical map Q* → P.Q |
| **`qstar_initial`** | Q* is initial among preserving quotients |
| `TBar_is_lift` | Descended operator is that unique lift |

## Diagram

```
         f
  State ──────▶ β
    │           ▲
   pi│          │ ∃! lift f
    ▼           │
   Q* ──────────┘
```

For a preserving quotient `(Q, p)`:

```
  State ──p──▶ Q
    │          ▲
   pi│         │ ∃! morphTo
    ▼          │
   Q* ─────────┘
```

## Relation to Drive theorem

Matches “Uniqueness of the Minimal Admissible Quotient”:
existence of Q*, uniqueness of the mediating morphism, minimality
as initiality among structure-preserving quotients.

## Build

```
lake build Chronofold
```
