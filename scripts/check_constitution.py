import re
import os
import glob

def check_lean():
    lean_files = glob.glob("**/*.lean", recursive=True)
    forbidden_tokens = ["sorry", "admit", "axiom", "unsafe"]
    defects = []
    for f in lean_files:
        if ".lake" in f:
            continue
        try:
            content = open(f, 'r').read()
            for token in forbidden_tokens:
                matches = re.findall(rf"\b{token}\b", content)
                if matches:
                    defects.append((f, token, len(matches)))
        except Exception as e:
            defects.append((f, "read_error", str(e)))
    return defects

def check_docs():
    required_docs = [
        "docs/CONSTITUTION_STATE.md",
        "docs/CLAIM_MATRIX.md",
        "docs/PROOF_GRAPH.md",
        "docs/DETERMINISM_REPORT.md",
        "docs/NEXT_OPERATOR.md"
    ]
    missing = [d for d in required_docs if not os.path.exists(d)]
    return missing

print("Lean defects:", check_lean())
print("Missing docs:", check_docs())
