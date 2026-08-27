#!/usr/bin/env bash
set -euo pipefail

# COCO/BBO-Bench Environment Setup Script
# This script sets up a Python virtual environment with COCO benchmark suite
# and BBO-Bench tooling (nevergrad, cocopp).

VENV_DIR="${VENV_DIR:-/tmp/coco-bbo-venv}"
PYTHON_VERSION="${PYTHON_VERSION:-3.13}"

echo "=== COCO/BBO-Bench Environment Setup ==="
echo "Python version: ${PYTHON_VERSION}"
echo "Virtualenv: ${VENV_DIR}"

# Create virtual environment
echo "Creating virtual environment..."
python${PYTHON_VERSION} -m venv "${VENV_DIR}" || {
    echo "Falling back to virtualenv..."
    pip install --user --break-system-packages virtualenv 2>/dev/null || true
    virtualenv "${VENV_DIR}"
}

# Activate virtual environment
source "${VENV_DIR}/bin/activate"

# Upgrade pip
pip install --upgrade pip

# Install dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Install COCO C framework (libcoco.so)
echo "Building COCO C framework..."
COCO_VERSION="2.6.3"
COCO_DIR="/tmp/coco-${COCO_VERSION}"
if [ ! -d "${COCO_DIR}" ]; then
    git clone --depth 1 --branch v${COCO_VERSION} https://github.com/numbbo/coco.git "${COCO_DIR}"
fi

cd "${COCO_DIR}/code-experiments/build/python"
python setup.py build_ext --inplace || {
    echo "Build failed, trying alternative build..."
    python do.py build-python || true
}

echo "=== Setup Complete ==="
echo "Activate with: source ${VENV_DIR}/bin/activate"
echo ""
echo "Installed packages:"
pip list | grep -E "coco|nevergrad|cocopp|numpy|scipy|pandas|scikit-learn|cython"
