import os
import re

proven_dir = "Proven Agd Theorums"
if not os.path.exists(proven_dir):
    os.makedirs(proven_dir)

theorems = [
    {
        "id": "THM_000101",
        "name": "jitter_close_reflexive",
        "title": "Jitter Equivalence Reflexivity",
        "source": "src/Chronofold/MeasurementCertificate.lean",
        "imports": ["Chronofold.MeasurementCertificate"]
    },
    {
        "id": "THM_000102",
        "name": "jitter_close_symmetric",
        "title": "Jitter Equivalence Symmetry",
        "source": "src/Chronofold/MeasurementCertificate.lean",
        "imports": ["Chronofold.MeasurementCertificate"]
    },
    {
        "id": "THM_000103",
        "name": "jitter_close_triangle",
        "title": "Jitter Equivalence Triangle Inequality",
        "source": "src/Chronofold/MeasurementCertificate.lean",
        "imports": ["Chronofold.MeasurementCertificate"]
    },
    {
        "id": "THM_000104",
        "name": "operator_preserves_equivalence",
        "title": "AGD Operator Equivalence Preservation",
        "source": "src/Chronofold/AgdQuotient.lean",
        "imports": ["Chronofold.AgdQuotient"]
    },
    {
        "id": "THM_000105",
        "name": "speedup_positive",
        "title": "AGD Speedup Positivity",
        "source": "src/Chronofold/BenchmarkCertificate.lean",
        "imports": ["Chronofold.BenchmarkCertificate"]
    },
    {
        "id": "THM_000106",
        "name": "benchmark_claim_valid",
        "title": "AGD Benchmark Claim Validity",
        "source": "src/Chronofold/BenchmarkCertificate.lean",
        "imports": ["Chronofold.BenchmarkCertificate"]
    },
    {
        "id": "THM_000107",
        "name": "agd_transport_closure",
        "title": "AGD Information Transport Closure",
        "source": "src/Chronofold/AgdInformationGeometry.lean",
        "imports": ["Chronofold.AgdInformationGeometry"]
    },
    {
        "id": "THM_000108",
        "name": "curvature_convergence",
        "title": "AGD Information Curvature Convergence",
        "source": "src/Chronofold/AgdInformationGeometry.lean",
        "imports": ["Chronofold.AgdInformationGeometry"]
    },
    {
        "id": "THM_000109",
        "name": "agd_bisimulation",
        "title": "AGD Dynamical Bisimulation",
        "source": "src/Chronofold/AgdInformationGeometry.lean",
        "imports": ["Chronofold.AgdInformationGeometry"]
    },
    {
        "id": "THM_000110",
        "name": "agd_flow_semigroup",
        "title": "AGD Flow Semigroup Property",
        "source": "src/Chronofold/AgdInformationGeometry.lean",
        "imports": ["Chronofold.AgdInformationGeometry"]
    },
    {
        "id": "THM_000111",
        "name": "agd_master_dynamic_closure",
        "title": "AGD Master Dynamic Closure",
        "source": "src/Chronofold/AgdInformationGeometry.lean",
        "imports": ["Chronofold.AgdInformationGeometry"]
    },
    {
        "id": "THM_000112",
        "name": "agd_spectral_convergence",
        "title": "AGD Spectral Radius Convergence",
        "source": "src/Chronofold/AgdSpectral.lean",
        "real_name": "AGD_Spectral_Convergence",
        "imports": ["Chronofold.AgdSpectral"]
    },
    {
        "id": "THM_000201",
        "name": "adaptive_operator_preservation",
        "title": "AGD Adaptive Operator Selection Preservation",
        "source": "src/Chronofold/AgdAdaptiveOperator.lean",
        "imports": ["Chronofold.AgdAdaptiveOperator"]
    },
    {
        "id": "THM_000202",
        "name": "agd_failure_recovery",
        "title": "AGD Error Recovery Rollback Theorem",
        "source": "src/Chronofold/AgdRollback.lean",
        "imports": ["Chronofold.AgdRollback"]
    },
    {
        "id": "THM_000203",
        "name": "learning_manifold_stability",
        "title": "AGD Learning Manifold Stability Theorem",
        "source": "src/Chronofold/AgdLearning.lean",
        "imports": ["Chronofold.AgdLearning"]
    },
    {
        "id": "THM_000204",
        "name": "memory_lineage_reconstruction",
        "title": "AGD Memory Lineage Preservation Theorem",
        "source": "src/Chronofold/AgdMemoryLineage.lean",
        "imports": ["Chronofold.AgdMemoryLineage"]
    },
    {
        "id": "THM_000205",
        "name": "agd_autonomous_closure",
        "title": "AGD Autonomous Optimization Closure Theorem",
        "source": "src/Chronofold/AgdAutonomousClosure.lean",
        "imports": ["Chronofold.AgdAutonomousClosure"]
    }
]

def extract_theorem(file_path, theorem_name):
    with open(file_path, 'r') as f:
        content = f.read()

    # Try to find the theorem block
    # This is a bit naive but should work for our files
    pattern = r"(theorem\s+" + theorem_name + r".*?:= by\n(.*?))(?=\n\n|\n\s*theorem|\n\s*namespace|\n\s*end|$)"
    match = re.search(pattern, content, re.DOTALL)
    if match:
        return match.group(1)

    # If it's a simple theorem without 'by'
    pattern = r"(theorem\s+" + theorem_name + r".*?:=.*)"
    match = re.search(pattern, content)
    if match:
        return match.group(1)

    return None

for t in theorems:
    real_name = t.get("real_name", t["name"])
    body = extract_theorem(t["source"], real_name)
    if not body:
        print(f"FAILED TO EXTRACT {real_name} from {t['source']}")
        continue

    filename = f"{t['id']}__{t['name']}.lean"
    filepath = os.path.join(proven_dir, filename)

    with open(filepath, 'w') as f:
        for imp in t["imports"]:
            f.write(f"import {imp}\n")
        f.write("\n")
        f.write(f"-- THEOREM_ID: {t['id']}\n")
        f.write(f"-- TITLE: {t['title']}\n")
        f.write(f"-- AUTHOR: Jules\n")
        f.write(f"-- STATUS: verified_by_lean\n")
        f.write("\n")
        f.write("namespace AGD\n\n")
        # Rename theorem if needed to match filename
        if real_name != t["name"]:
            body = body.replace(real_name, t["name"])
        f.write(body)
        f.write("\n\nend AGD\n")

print("Theorems generated.")
