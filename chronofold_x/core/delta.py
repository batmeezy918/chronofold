import numpy as np

class Delta:
    """Deterministic DAG Execution Engine"""
    def compute_topological_order(self, graph):
        nodes = {n["id"]: n for n in graph["nodes"]}
        adj = {n["id"]: [] for n in graph["nodes"]}
        in_degree = {n["id"]: 0 for n in graph["nodes"]}

        for edge in graph["edges"]:
            u, v = edge["from"], edge["to"]
            adj[u].append(v)
            in_degree[v] += 1

        queue = sorted([n_id for n_id, deg in in_degree.items() if deg == 0])
        order = []

        while queue:
            u = queue.pop(0)
            order.append(u)

            for v in sorted(adj[u]):
                in_degree[v] -= 1
                if in_degree[v] == 0:
                    queue.append(v)
                    queue.sort()

        if len(order) != len(nodes):
            raise ValueError("Cycle detected in graph topology")

        return order

    def propagate_state(self, psi_k, psi_next, epsilon=0.01):
        """Propagation bound: ||Ψ(k+1) - Ψ(k)|| <= ε"""
        # Sum of Euclidean distances between node vectors
        dist = 0.0
        nodes_k = {n["id"]: n for n in psi_k["nodes"]}
        nodes_next = {n["id"]: n for n in psi_next["nodes"]}

        for n_id, node in nodes_next.items():
            if n_id in nodes_k:
                v1 = np.array(nodes_k[n_id].get("vector", [0]*16))
                v2 = np.array(node.get("vector", [0]*16))
                dist += np.linalg.norm(v1 - v2)

        return dist <= epsilon
