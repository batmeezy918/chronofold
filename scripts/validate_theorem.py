import re
import sys
from pathlib import Path

FILE = Path(sys.argv[1])
text = FILE.read_text()

# filename validation
name = FILE.name
if not re.match(r"THM_\d{6}__([a-z0-9_]+)\.lean", name):
    print("INVALID FILENAME")
    sys.exit(1)

theorem_name = re.findall(r"theorem\s+([a-zA-Z0-9_]+)", text)
if len(theorem_name) != 1:
    print("MUST HAVE EXACTLY ONE THEOREM")
    sys.exit(1)

suffix = name.split("__",1)[1].replace(".lean","")
if theorem_name[0] != suffix:
    print("THEOREM NAME MISMATCH")
    sys.exit(1)

# metadata validation
required = ["THEOREM_ID:", "TITLE:", "AUTHOR:", "STATUS:"]
for r in required:
    if r not in text:
        print(f"MISSING {r}")
        sys.exit(1)

# forbidden tokens
forbidden = ["sorry", "admit", "axiom", "unsafe"]
for token in forbidden:
    if token in text:
        print(f"FORBIDDEN TOKEN: {token}")
        sys.exit(1)

print("VALID")
