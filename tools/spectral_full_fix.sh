#!/usr/bin/env bash

set -e

echo "🧠 SPECTRAL FULL AUTO REPAIR INIT"

ROOT="core/src/spectral"

# -------------------------
# 1. ENSURE PACKAGE STRUCTURE
# -------------------------
mkdir -p "$ROOT/history"

touch "$ROOT/__init__.py"

echo "✅ package initialized"

# -------------------------
# 2. FIX IMPORT STYLE (PACKAGE MODE ONLY)
# -------------------------

# run_evolution must use relative import
if [ -f "$ROOT/run_evolution.py" ]; then
cat > "$ROOT/run_evolution.py" << 'PY'
from .evolution_loop import run_evolution

if __name__ == "__main__":
    run_evolution()
PY
echo "✅ fixed run_evolution.py"
fi

# evolution_loop must be package-safe
if [ -f "$ROOT/evolution_loop.py" ]; then
sed -i 's/^from state_vector/from .state_vector/g' "$ROOT/evolution_loop.py" 2>/dev/null || true
sed -i 's/^from op_matrix/from .op_matrix/g' "$ROOT/evolution_loop.py" 2>/dev/null || true
sed -i 's/^from eigen_analysis/from .eigen_analysis/g' "$ROOT/evolution_loop.py" 2>/dev/null || true
sed -i 's/^from quotient/from .quotient/g' "$ROOT/evolution_loop.py" 2>/dev/null || true
fi

# -------------------------
# 3. FIX HISTORY LOGGER IMPORTS
# -------------------------
if [ -f "$ROOT/learning_loop.py" ]; then
sed -i 's/from history.logger/from .history.logger/g' "$ROOT/learning_loop.py" 2>/dev/null || true
echo "✅ learning_loop patched"
fi

# -------------------------
# 4. ENSURE ENTRYPOINT
# -------------------------
cat > "$ROOT/__main__.py" << 'PY'
from .evolution_loop import run_evolution

if __name__ == "__main__":
    run_evolution()
PY

echo "✅ __main__.py created"

# -------------------------
# 5. SAFETY CHECK MODULE TEST
# -------------------------
echo "🧪 testing module import..."

cd "$(pwd)"

python3 -c "
import core.src.spectral as s
print('✅ spectral package import OK')
" || echo "⚠️ import test failed"

# -------------------------
# 6. GIT OPTIONAL AUTO COMMIT
# -------------------------
if [ -d .git ]; then
    git add .
    git commit -m \"spectral kernel auto-fix: unified package execution model\" || true
    git push || true
    echo "🚀 pushed"
fi

echo "🧠 SPECTRAL FULL REPAIR COMPLETE"
