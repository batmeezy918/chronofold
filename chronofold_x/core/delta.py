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

        # Lexicographic tie-breaking for determinism
        queue = sorted([n_id for n_id, deg in in_degree.items() if deg == 0])
        order = []

        while queue:
            u = queue.pop(0)
            order.append(u)

            for v in sorted(adj[u]):
                in_degree[v] -= 1
                if in_degree[v] == 0:
                    queue.append(v)
                    queue.sort() # Maintain lexicographic order

        if len(order) != len(nodes):
            raise ValueError("Cycle detected in graph topology")

        return order

    def propagate_state(self, graph, epsilon=0.01):
        # Implementation of bounded state propagation ||Psi_k+1 - Psi_k|| <= epsilon
        pass
