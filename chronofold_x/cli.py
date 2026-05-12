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
    with open(input_path) as f:
        graph = yaml.safe_load(f) if input_path.endswith((".yaml", ".yml")) else json.load(f)

    omega = Omega()
    psi = omega.normalize(graph)

    delta = Delta()
    psi["execution_order"] = delta.compute_topological_order(psi)

    xi = Xi()
    valid, msg = xi.validate(psi)
    if not valid:
        print(f"Validation Failed: {msg}")
        return

    lambda_opt = LambdaOpt()
    optimized_psi = lambda_opt.optimize(psi)

    emitter = Emitter()
    output_dir = "android_generated_project"
    emitter.generate_project(optimized_psi, output_dir)

    print(f"Project generated at {output_dir}")
    print(f"Canonical Hash: {compute_state_hash(optimized_psi)}")

    # Section 14: Gradle Build
    print("Invoking Gradle Build...")
    try:
        # Check if gradle exists in path
        subprocess.run(["gradle", "--version"], capture_output=True, check=True)
        # We don't have a full project with gradlew yet, so we'd use 'gradle'
        # subprocess.run(["gradle", "assembleDebug", "--offline", "--no-daemon"], cwd=output_dir)
        print("Gradle found. (Actual build requires full Android SDK environment)")
    except:
        print("Gradle not found. Skipping build.")

def verify_lean():
    """Lean4 Bridge Integration (Section 12)"""
    print("Verifying structural proofs with Lean4...")
    try:
        res = subprocess.run(["lake", "build", "ChronoFold"], capture_output=True, text=True)
        if res.returncode == 0:
            print("Lean4 verification: SUCCESS")
        else:
            print(f"Lean4 verification: FAILED\n{res.stderr}")
    except Exception as e:
        print(f"Lean4 Bridge Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "build" and len(sys.argv) > 2:
            build(sys.argv[2])
        elif cmd == "verify":
            verify_lean()
        elif cmd == "inspect" and len(sys.argv) > 2:
            # Re-implementing inspect
            with open(sys.argv[2]) as f:
                graph = yaml.safe_load(f) if sys.argv[2].endswith((".yaml", ".yml")) else json.load(f)
            print(json.dumps(Omega().normalize(graph), indent=2))
