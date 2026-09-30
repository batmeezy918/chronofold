import Verify

/--
THEOREM_ID: THM_000010
TITLE: spectral_closure_verification
AUTHOR: operator
STATUS: candidate
-/

theorem spectral_closure_verification
    (α : Type u) (inv : AGD.Invariants α) (sc : AGD.SpectralClosureOperator α inv) (s : AGD.State α) :
    inv.omega (sc.spectralOp s) = inv.omega s ∧ inv.covariant (sc.spectralOp s) = inv.covariant s :=
  AGD.spectral_closure_step_preserves_invariants α inv sc s
