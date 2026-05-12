import hashlib
import json

class Xi:
    """Admissibility Engine"""
    def validate(self, graph):
        # 1. Schema Correctness
        if "nodes" not in graph or "edges" not in graph:
            return False, "Missing nodes or edges"

        # 2. Hash Correctness
        for node in graph["nodes"]:
            if "hash" not in node:
                return False, f"Node {node.get('id')} missing hash"

        # 3. DAG Validity
        try:
            from .delta import Delta
            Delta().compute_topological_order(graph)
        except ValueError as e:
            return False, str(e)

        return True, "Valid"
