cat << 'EOF' > stability_check.py
import json, os

ROOT = os.path.expanduser("~/chronofold_analysis/_EXPORT_DATASET/results")
print(f"{'FILE':<30} | {'STABILITY SCORE':<20}")
print("-" * 55)

if os.path.exists(ROOT):
    for f in sorted(os.listdir(ROOT)):
        if f.endswith(".json"):
            try:
                with open(os.path.join(ROOT, f), 'r') as j:
                    data = json.load(j)
                    # Extract the score from the SPHERE manifold
                    score = data.get('SPHERE', 'N/A')
                    print(f"{f:<30} | {score}")
            except Exception as e:
                print(f"Error reading {f}: {e}")
else:
    print("Error: Path not found. Check your manifold alignment.")
EOF
python stability_check.py

