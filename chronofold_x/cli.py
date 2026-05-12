import sys
import json
import yaml
import os
import subprocess
from core.omega import Omega
from core.delta import Delta
from core.xi import Xi
from core.lambda_opt import LambdaOpt
from core.emitter import Emitter
from core.hashing import compute_state_hash

def build(input_path):
    # LOAD
    with open(input_path) as f:
        if input_path.endswith((".yaml", ".yml")):
            graph = yaml.safe_load(f)
        else:
            graph = json.load(f)

    # Ω - NORMALIZE
    omega = Omega()
    psi = omega.normalize(graph)

    # Δ - DAG EXECUTION
    delta = Delta()
    psi["execution_order"] = delta.compute_topological_order(psi)

    # Ξ - ADMISSIBILITY
    xi = Xi()
    valid, msg = xi.validate(psi)
    if not valid:
        print(f"Ξ Validation Failed: {msg}")
        return

    # Λ - OPTIMIZE
    lambda_opt = LambdaOpt()
    optimized_psi = lambda_opt.optimize(psi)

    # E - EMIT
    emitter = Emitter()
    output_dir = "android_generated_project"
    emitter.generate_project(optimized_psi, output_dir)

    # H - HASHING
    final_hash = compute_state_hash(optimized_psi)
    print(f"SUCCESS: Chronofold_X Build Complete")
    print(f"Canonical Hash: {final_hash}")

    # Invoke Gradle (simulated/dry-run)
    # subprocess.run(["./gradlew", "assembleDebug", "--offline", "--no-daemon"], cwd=output_dir)

def inspect(input_path):
    with open(input_path) as f:
        graph = yaml.safe_load(f) if input_path.endswith((".yaml", ".yml")) else json.load(f)
    omega = Omega()
    psi = omega.normalize(graph)
    print(json.dumps(psi, indent=2))

if __name__ == "__main__":
    if len(sys.argv) > 2:
        cmd = sys.argv[1]
        path = sys.argv[2]
        if cmd == "build":
            build(path)
        elif cmd == "inspect":
            inspect(path)
        else:
            print("Unknown command")
    else:
        print("Usage: python cli.py [build|inspect] <path>")
