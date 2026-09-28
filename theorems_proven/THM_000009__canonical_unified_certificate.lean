import Verify

/--
THEOREM_ID: THM_000009
TITLE: canonical_unified_certificate
AUTHOR: operator
STATUS: candidate
-/

theorem canonical_unified_certificate
    (α : Type u) (inv : AGD.Invariants α) (cert : AGD.UnifiedCertificateOperator α inv) (s : AGD.State α) :
    inv.omega (cert.certOp s) = inv.omega s ∧ inv.covariant (cert.certOp s) = inv.covariant s :=
  AGD.unified_certificate_step_preserves_invariants α inv cert s
