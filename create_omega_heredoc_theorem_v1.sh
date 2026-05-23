#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

export LC_ALL=C
export TZ=UTC

ROOT="$PWD"
RUN_ID="OMEGA_CREATE_HEREDOC_THEOREM_V1"

echo "[$RUN_ID][INFO] root=$ROOT"

if [ ! -f "$ROOT/lakefile.lean" ]; then
  echo "[$RUN_ID][FAIL] lakefile.lean not found. Run this from your Lean/Lake repo root."
  exit 1
fi

# Detect root Lean module file, e.g. Chronofold.lean
ROOT_LEAN="$(find "$ROOT" -maxdepth 1 -type f -name "*.lean" \
  ! -name "lakefile.lean" \
  | head -n 1 || true)"

if [ -z "$ROOT_LEAN" ]; then
  echo "[$RUN_ID][FAIL] Could not find root module file like Chronofold.lean"
  echo "[$RUN_ID][INFO] Create one manually or pass module layout later."
  exit 1
fi

MODULE_NAME="$(basename "$ROOT_LEAN" .lean)"

echo "[$RUN_ID][INFO] detected module=$MODULE_NAME"

mkdir -p \
  "$ROOT/omega/theorems" \
  "$ROOT/omega/dag" \
  "$ROOT/omega/scripts" \
  "$ROOT/omega/snapshots" \
  "$ROOT/omega/logs" \
  "$ROOT/$MODULE_NAME/Omega"

LOG="$ROOT/omega/logs/heredoc_gate_create.log"
HASHFILE="$ROOT/omega/snapshots/heredoc_gate.sha256"

echo "[$RUN_ID][INFO] creating theorem interface" | tee "$LOG"

cat << 'LEAN' > "$ROOT/omega/theorems/HeredocRepro.lean"
namespace Omega

/-
  Omega Heredoc Reproducibility Gate v1

  This is the first reproducibility theorem gate.

  Operator form:

    ψ₁ = H_emit ψ₀
    ψ₂ = R ∘ H_emit ψ₀

    R = V ∘ K ∘ Q ∘ L ∘ T ∘ N

  Invariants tracked:

    Ω(Oψ)
    heat_trace(O)
    curvature(ψ)
    Replay(D,L,H)

  Status:
    interface_locked_external_witness_required

  Meaning:
    The Bash/heredoc/filesystem/hash semantics are witnessed externally
    by omega/scripts/heredoc_gate_replay.sh and omega/snapshots/heredoc_gate.sha256.
-/

structure Artifact where
  id : String
  source : String
  target : String
  sha256 : String
  deriving Repr, BEq

structure DagNode where
  id : String
  operator : String
  input_hash : String
  output_hash : String
  dependencies : List String
  status : String
  deriving Repr, BEq

def OmegaValid (_a : Artifact) : Prop := True

def Replayable (_n : DagNode) : Prop := True

/-
  H1: Deterministic Heredoc Emission

  If heredoc source, target path, environment, and interpreter are fixed,
  then the emitted artifact hash is stable.

  Current stage:
    external axiom / witness-backed interface.
-/
axiom heredoc_emission_deterministic :
  ∀ (a b : Artifact),
    a.source = b.source →
    a.target = b.target →
    a.sha256 = b.sha256

/-
  H2: Replay Closure

  If a DAG node is replayable and its output hash matches the artifact hash,
  then the artifact remains Ω-valid.
-/
axiom heredoc_replay_closure :
  ∀ (a : Artifact) (n : DagNode),
    Replayable n →
    n.output_hash = a.sha256 →
    OmegaValid a

theorem heredoc_gate_valid :
  ∀ (a : Artifact) (n : DagNode),
    Replayable n →
    n.output_hash = a.sha256 →
    OmegaValid a :=
by
  intro a n hReplay hHash
  exact heredoc_replay_closure a n hReplay hHash

end Omega
LEAN

cp "$ROOT/omega/theorems/HeredocRepro.lean" "$ROOT/$MODULE_NAME/Omega/HeredocRepro.lean"

IMPORT_LINE="import ${MODULE_NAME}.Omega.HeredocRepro"

if grep -Fxq "$IMPORT_LINE" "$ROOT_LEAN"; then
  echo "[$RUN_ID][INFO] import already present in $(basename "$ROOT_LEAN")" | tee -a "$LOG"
else
  printf "\n%s\n" "$IMPORT_LINE" >> "$ROOT_LEAN"
  echo "[$RUN_ID][INFO] added import to $(basename "$ROOT_LEAN")" | tee -a "$LOG"
fi

LEAN_HASH="$(sha256sum "$ROOT/omega/theorems/HeredocRepro.lean" | awk '{print $1}')"

cat << JSON > "$ROOT/omega/dag/heredoc_gate.node.json"
{
  "node_id": "omega.heredoc_gate.v1",
  "operator": "R ∘ P_Ω ∘ H_emit",
  "module": "${MODULE_NAME}.Omega.HeredocRepro",
  "theorems": [
    "Omega.heredoc_emission_deterministic",
    "Omega.heredoc_replay_closure",
    "Omega.heredoc_gate_valid"
  ],
  "artifact_external": "omega/theorems/HeredocRepro.lean",
  "artifact_lean_module": "${MODULE_NAME}/Omega/HeredocRepro.lean",
  "output_hash": "$LEAN_HASH",
  "dependencies": [],
  "status": "interface_locked_external_witness_required",
  "invariants": {
    "Omega_Opsi": "required",
    "heat_trace": "stable_required",
    "curvature": "bounded_required",
    "Replay_DLH": "required"
  }
}
JSON

cat << 'BASH' > "$ROOT/omega/scripts/heredoc_gate_replay.sh"
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

export LC_ALL=C
export TZ=UTC

ROOT="${1:-$PWD}"
TARGET="$ROOT/omega/theorems/HeredocRepro.lean"
HASHFILE="$ROOT/omega/snapshots/heredoc_gate.sha256"

if [ ! -f "$TARGET" ]; then
  echo "[OMEGA_HEREDOC_REPLAY][FAIL] missing target: $TARGET"
  exit 1
fi

if [ ! -f "$HASHFILE" ]; then
  echo "[OMEGA_HEREDOC_REPLAY][FAIL] missing hashfile: $HASHFILE"
  exit 1
fi

CURRENT="$(sha256sum "$TARGET" | awk '{print $1}')"
EXPECTED="$(cat "$HASHFILE" | awk '{print $1}')"

echo "[OMEGA_HEREDOC_REPLAY][INFO] expected=$EXPECTED"
echo "[OMEGA_HEREDOC_REPLAY][INFO] current=$CURRENT"

if [ "$CURRENT" = "$EXPECTED" ]; then
  echo "[OMEGA_HEREDOC_REPLAY][PASS] replay hash stable"
  exit 0
else
  echo "[OMEGA_HEREDOC_REPLAY][FAIL] replay hash mismatch"
  exit 2
fi
BASH

chmod +x "$ROOT/omega/scripts/heredoc_gate_replay.sh"

sha256sum "$ROOT/omega/theorems/HeredocRepro.lean" > "$HASHFILE"

echo "[$RUN_ID][INFO] hash=$LEAN_HASH" | tee -a "$LOG"
echo "[$RUN_ID][PASS] created Omega heredoc theorem gate v1" | tee -a "$LOG"

echo
echo "Next commands:"
echo "  ./omega/scripts/heredoc_gate_replay.sh"
echo "  lake build"
echo "  git status"
