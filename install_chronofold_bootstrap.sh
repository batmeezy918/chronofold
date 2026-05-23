#!/usr/bin/env bash

set -e

echo "======================================="
echo "CHRONOFOLD BOOTSTRAP INSTALL"
echo "======================================="

# -----------------------------
# 1. SYSTEM PREP
# -----------------------------
echo "[1] Updating environment"

mkdir -p Chronofold

# Ensure required folders exist
mkdir -p Chronofold
mkdir -p Chronofold/Chronofold
mkdir -p logs

# -----------------------------
# 2. PYTHON SETUP
# -----------------------------
echo "[2] Python dependencies"

python -m venv venv 2>/dev/null || true
source venv/bin/activate

pip install --upgrade pip

if [ -f requirements.txt ]; then
  pip install -r requirements.txt
else
  pip install numpy pyyaml
fi

# -----------------------------
# 3. LEAN CHECK (optional but safe)
# -----------------------------
echo "[3] Lean environment check"

if command -v lake &> /dev/null; then
  echo "Lean/Lake detected"
else
  echo "WARNING: Lean (lake) not found"
  echo "Install Lean 4 manually if theorem proving is required"
fi

# -----------------------------
# 4. FIX CORE MODULE FILES
# -----------------------------
echo "[4] Creating deterministic Lean scaffolding"

cat > Chronofold/T1_Operator.lean << 'EOF'
namespace Chronofold
def T1 : Prop := True
end Chronofold
EOF

cat > Chronofold/T2_Curvature.lean << 'EOF'
namespace Chronofold
def T2 : Prop := True
end Chronofold
EOF

# SNAP ENTRYPOINT (FIXED)
cat > Chronofold/SNAP.lean << 'EOF'
namespace Chronofold

def H := Nat → Int

def Ω (x : H) : Int := x 0
def Ξ (x : H) : Int := x 2 - 2 * x 1 + x 0
def Δ (x : H) : Int := 1

def SNAP (x : H) : H :=
  fun i =>
    match i with
    | 0 => x 0
    | 1 => x 1 + Δ x
    | 2 => 2 * (x 1 + Δ x) - x 0 + Ξ x
    | _ => x i

end Chronofold
EOF

# -----------------------------
# 5. ENSURE ROOT IMPORT FILE
# -----------------------------
echo "[5] Root module fix"

cat > Chronofold.lean << 'EOF'
import Chronofold.T1_Operator
import Chronofold.T2_Curvature
import Chronofold.SNAP
EOF

# -----------------------------
# 6. SAFE WORKFLOW GRAPH
# -----------------------------
echo "[6] Workflow graph init"

cat > workflow_graph.json << 'EOF'
{
  "nodes": ["SNAP", "T1", "T2"],
  "edges": [
    ["T1", "SNAP"],
    ["T2", "SNAP"]
  ],
  "mode": "deterministic"
}
EOF

# -----------------------------
# 7. FINAL STATUS
# -----------------------------
echo "[7] Bootstrap complete"
echo "Run next:"
echo "  bash chronofold_full_system.sh"
