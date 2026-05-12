import json
import hashlib
import numpy as np

class Omega:
    """Canonical Semantic Normalization Layer"""
    def __init__(self, max_iter=5):
        self.max_iter = max_iter

    def normalize(self, graph):
        current_graph = graph
        for i in range(self.max_iter):
            prev_hash = self.get_hash(current_graph)
            current_graph = self._normalize_pass(current_graph)
            new_hash = self.get_hash(current_graph)
            if prev_hash == new_hash:
                break
        return current_graph

    def _normalize_pass(self, graph):
        # 1. Canonicalize node ordering
        nodes = sorted(graph.get("nodes", []), key=lambda x: x.get("id"))

        # 2. Vectorize semantics (Deterministic embedding)
        for node in nodes:
            node["vector"] = self._vectorize(node).tolist()
            node["hash"] = self.get_node_hash(node)

        # 3. Canonicalize edge ordering
        edges = sorted(graph.get("edges", []), key=lambda x: (x.get("from"), x.get("to")))

        return {
            "nodes": nodes,
            "edges": edges,
            "meta": graph.get("meta", {}),
            "constraints": graph.get("constraints", {})
        }

    def _deterministic_hash(self, s):
        return int(hashlib.sha256(str(s).encode()).hexdigest(), 16)

    def _vectorize(self, node):
        # v_i = phi(type, dependencies, constraints, ui_role)
        v = np.zeros(16)
        v[0] = self._deterministic_hash(node.get("type", "")) % 100
        v[1] = self._deterministic_hash(node.get("ui_role", "")) % 100
        v[2] = len(node.get("dependencies", []))
        v[3] = self._deterministic_hash(node.get("constraints", "")) % 100

        norm = np.linalg.norm(v)
        if norm > 0:
            v = v / norm
        return v

    def get_node_hash(self, node):
        data = {k: v for k, v in node.items() if k != "hash" and k != "vector"}
        return hashlib.sha256(json.dumps(data, sort_keys=True).encode()).hexdigest()

    def get_hash(self, graph):
        return hashlib.sha256(json.dumps(graph, sort_keys=True).encode()).hexdigest()
