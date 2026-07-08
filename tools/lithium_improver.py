import subprocess
import os
import sys

class LithiumImprover:
    """
    Automates the AGD Lean 4 Proof Cycle:
    Build -> Detect Errors -> Refactor -> Verify Invariants.
    """

    def __init__(self, target_dir="src/Chronofold"):
        self.target_dir = target_dir

    def run_build(self):
        print("Lithium Loop: Starting Lake Build...")
        result = subprocess.run(["lake", "build"], capture_output=True, text=True)
        return result.returncode == 0, result.stderr

    def check_for_sorry(self):
        print("Lithium Loop: Checking for 'sorry' placeholders...")
        # Check all .lean files in target_dir
        cmd = f"grep -r 'sorry' {self.target_dir}"
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return len(result.stdout.strip()) == 0

    def validate_proven_folder(self, proven_dir="Proven Agd Theorums"):
        print(f"Lithium Loop: Validating {proven_dir} artifacts...")
        validator = "tools/scripts/validate_theorem.py"
        all_valid = True
        for f in os.listdir(proven_dir):
            if f.endswith(".lean"):
                path = os.path.join(proven_dir, f)
                res = subprocess.run(["python3", validator, path], capture_output=True, text=True)
                if "VALID" not in res.stdout:
                    print(f"ERROR: {f} failed validation: {res.stdout}")
                    all_valid = False
        return all_valid

    def execute_full_cycle(self):
        build_pass, errors = self.run_build()
        if not build_pass:
            print("LITHIUM STATUS: BUILD FAILED")
            print(errors)
            return False

        if not self.check_for_sorry():
            print("LITHIUM STATUS: SORRY DETECTED")
            return False

        if not self.validate_proven_folder():
            print("LITHIUM STATUS: ARTIFACT VALIDATION FAILED")
            return False

        print("LITHIUM STATUS: AGD OPTIMIZED (0 Stars, 0 Errors)")
        return True

if __name__ == "__main__":
    improver = LithiumImprover()
    if improver.execute_full_cycle():
        sys.exit(0)
    else:
        sys.exit(1)
