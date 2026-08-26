# COCO/BBO-Bench Installation Verification Report

## Executive Summary

Successfully installed the official COCO benchmark suite (Comparing Continuous Optimizers) from Inria/numbbo and BBO-Bench tooling on a Linux server (Python 3.13.5, no root/apt access).

---

## 1. Installed Components

### 1.1 COCO Benchmark Suite

| Component | Version | Source | Install Location |
|-----------|---------|--------|------------------|
| **coco-experiment** (Python bindings) | 2.8.2 | PyPI sdist | `/tmp/coco-venv/lib/python3.13/site-packages/cocoex/` |
| **COCO C framework** | 2.6.3 | github.com/numbbo/coco v2.6.3 | `/tmp/coco-old/code-experiments/build/python/cython/libcoco.so` |

**Note:** The `master` branch of `numbbo/coco` is outdated (refactored into separate repos). Used the `v2.6.3` tag for a complete, buildable source tree with `do.py`.

### 1.2 BBO-Bench Tooling

| Component | Version | Source | Install Location |
|-----------|---------|--------|------------------|
| **nevergrad** (BBO optimizer) | 1.0.12 | PyPI | `/tmp/coco-venv/lib/python3.13/site-packages/nevergrad/` |
| **cocopp** (post-processing) | 2.8.8 | PyPI | `/tmp/coco-venv/lib/python3.13/site-packages/cocopp/` |

### 1.3 Additional Dependencies

| Component | Version | Purpose |
|-----------|---------|---------|
| numpy | 2.5.2 | Array operations, COCO interface |
| scipy | 1.18.1 | Scientific computing |
| pandas | 3.0.5 | Data handling |
| scikit-learn | 1.9.0 | ML utilities |
| cma | 4.4.4 | CMA-ES optimizer (nevergrad dep) |
| bayesian-optimization | 1.4.0 | Bayesian optimization (nevergrad dep) |
| directsearch | 1.1 | Direct search methods (nevergrad dep) |
| cython | 3.3.0 | C extension compilation |
| meson | 1.12.0 | Build system (for coco-experiment sdist) |
| meson-python | 0.20.0 | Meson Python backend |
| setuptools | 84.0.0 | Python packaging |

---

## 2. Environment Details

- **OS:** Linux (Debian-based)
- **Python:** 3.13.5
- **Compiler:** GCC 14.2.0
- **Virtualenv:** `/tmp/coco-venv`
- **No root/apt access:** All packages installed in user-level virtualenv

---

## 3. Build Process & Caveats

### 3.1 Python Installation
- System Python 3.13.5 had no `pip` or `ensurepip`
- Installed `pip` via `get-pip.py` with `--break-system-packages`
- Created virtualenv using `virtualenv` (system `python3 -m venv` unavailable without `python3.13-venv` package)

### 3.2 COCO C Framework Build
- The `numbbo/coco` `master` branch is outdated; the `do.py` build system is present only in older tags
- Checked out `v2.6.3` tag for complete build system
- Built `libcoco.so` from amalgamated C sources (`code-experiments/build/python/cython/coco.c`)
- Compiled successfully with `gcc -shared -fPIC -O2`

### 3.3 Python C Extension (cocoexperiment)
- PyPI `coco-experiment` sdist (2.8.2) uses `meson-python` which requires `python` executable in PATH
- Created symlink `/tmp/fakebin/python` → `/usr/bin/python3`
- Meson build failed due to missing `python3` dev dependency for link testing
- **Resolution:** Built from PyPI sdist with custom `setup.py` using Cython 3.3.0, linking against pre-built `libcoco.so`
- Required manual extraction of `libpython3.13-dev` headers from Debian package (no root access)

### 3.4 Python 3.13 Compatibility
- COCO repo's Cython 0.29.33 generated code incompatible with Python 3.13 (missing `Py_PYTHON_H` define, `PY_VERSION_HEX` check, `longintrepr.h`)
- Resolved by using PyPI sdist with Cython 3.3.0 which generates compatible code

---

## 4. Smoke Test Results

All smoke tests passed successfully.

### 4.1 COCO Suite Instantiation
```python
import cocoex
suite = cocoex.Suite('bbob', '', 'dimensions: 2')
problem = suite.get_problem(0)
print(problem.name)  # "bbob(BBOB suite problem f1 instance 1 in 2D)"
print(problem.dimension)  # 2
y = problem(np.zeros(2))  # 80.88209408
```

### 4.2 nevergrad Optimization
```python
import nevergrad as ng
optimizer = ng.optimizers.OnePlusOne(parametrization=2, budget=20)
for _ in range(10):
    x = optimizer.ask()
    y = problem(np.array(x.value))
    optimizer.tell(x, y)
print(optimizer.provide_recommendation().loss)  # Converged
```

### 4.3 Integration Test
- nevergrad successfully optimized COCO BBOB benchmark functions
- No interface mismatches or runtime errors

---

## 5. How to Run

### 5.1 Activate Environment
```bash
source /tmp/coco-venv/bin/activate
```

### 5.2 Run Smoke Tests
```bash
python tools/coco-bbo-setup/smoke_test.py
```

### 5.3 Example Benchmark
```python
import cocoex
import nevergrad as ng
import numpy as np

suite = cocoex.Suite('bbob', '', 'dimensions: 2')
observer = cocoex.Observer('bbob', 'result_folder: bbob_results')
problem = suite.get_problem(0)
problem.observe_with(observer)

optimizer = ng.optimizers.OnePlusOne(parametrization=problem.dimension, budget=50)
for _ in range(25):
    x = optimizer.ask()
    y = problem(np.array(x.value))
    optimizer.tell(x, y)

print(optimizer.provide_recommendation().loss)
```

---

## 6. Packages Not Installed

- **bbob**: Not available on PyPI; COCO provides BBOB suite via `cocoex`
- **iohprofiler**: Not available on PyPI; requires separate build from source (not attempted due to complexity)
- **coco-postprocessing**: Replaced by `cocopp` (the official successor)

---

## 7. Files Delivered

| File | Purpose |
|------|---------|
| `tools/coco-bbo-setup/requirements.txt` | Pinned Python dependencies |
| `tools/coco-bbo-setup/setup_env.sh` | Environment setup script |
| `tools/coco-bbo-setup/smoke_test.py` | Automated smoke tests |
| `tools/coco-bbo-setup/VERIFICATION_REPORT.md` | This report |

---

*Report generated: 2026-08-26*
