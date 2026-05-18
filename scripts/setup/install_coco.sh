#!/usr/bin/env bash

echo "=== INSTALLING SYSTEM DEPENDENCIES ==="

sudo apt update
sudo apt install -y git python3 python3-venv python3-pip build-essential cmake

echo "=== CLONING COCO ==="

git clone https://github.com/numbbo/coco.git
cd coco/code-experiments/build/python

echo "=== SETTING UP PYTHON ENV ==="

python3 -m venv coco_env
source coco_env/bin/activate

pip install --upgrade pip
pip install numpy

echo "=== BUILDING COCO ==="

python setup.py install

echo "=== VERIFY ==="

python -c "import cocoex; print('COCO READY')"

echo "=== DONE ==="
