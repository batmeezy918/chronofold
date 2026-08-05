import json
import hashlib
import numpy as np


class Omega:
    """Canonical Semantic Normalization Layer (hash-stable)."""

    def __init__(self, max_iter=5):
        self.max_iter = max_iter

    def normalize(self, graph):
        current_graph = graph
        for _ in range(self.max_iter):
            prev_hash = self.get_hash(current_graph)
            current_graph = self._normalize_pass(current_graph)
            new_hash = self.get_hash(current_graph)
            if prev_hash == new_hash:
                break
        return current_graph

    def _normalize_pass(self, graph):
        nodes = sorted(graph.get("nodes", []), key=lambda x: x.get("id"))
        for node in nodes:
            node["vector"] = self._vectorize(node).tolist()
            node["hash"] = self.get_node_hash(node)
        edges = sorted(
            graph.get("edges", []),
            key=lambda x: (x.get("from"), x.get("to")),
        )
        return {
            "nodes": nodes,
            "edges": edges,
            "meta": graph.get("meta", {}),
            "constraints": graph.get("constraints", {}),
        }

    def _deterministic_hash(self, s):
        return int(hashlib.sha256(str(s).encode()).hexdigest(), 16)

    def _vectorize(self, node):
        v = np.zeros(16)
        v[0] = self._deterministic_hash(node.get("type", "")) % 100
        v[1] = self._deterministic_hash(node.get("ui_role", "")) % 100
        v[2] = len(node.get("dependencies", []))
        v[3] = self._deterministic_hash(node.get("constraints", "")) % 100
        norm = np.linalg.norm(v)
        if norm > 0:
            v = v / norm
        # quantize for cross-platform hash stability
        return np.round(v, 8)

    def get_node_hash(self, node):
        data = {
            k: v
            for k, v in node.items()
            if k not in ("hash", "vector")
        }
        return hashlib.sha256(
            json.dumps(data, sort_keys=True, default=str).encode()
        ).hexdigest()

    def get_hash(self, graph):
        """Hash only stable fields; round any float vectors."""

        def stabilize(obj):
            if isinstance(obj, float):
                return round(obj, 8)
            if isinstance(obj, dict):
                return {
                    k: stabilize(v)
                    for k, v in sorted(obj.items())
                    if k != "hash"
                }
            if isinstance(obj, list):
                return [stabilize(x) for x in obj]
            return obj

        stable = stabilize(graph)
        return hashlib.sha256(
            json.dumps(stable, sort_keys=True, default=str).encode()
        ).hexdigest()
