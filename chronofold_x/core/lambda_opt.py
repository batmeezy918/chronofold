class LambdaOpt:
    """Graph Optimization Layer"""
    def optimize(self, graph):
        # 1. Deduplicate Nodes
        seen_hashes = set()
        unique_nodes = []
        node_id_map = {}

        for node in graph.get("nodes", []):
            h = node.get("hash")
            if h not in seen_hashes:
                seen_hashes.add(h)
                unique_nodes.append(node)
            else:
                # Map old ID to the ID of the first node with this hash
                original = next(n for n in unique_nodes if n["hash"] == h)
                node_id_map[node["id"]] = original["id"]

        # 2. Update Edges
        unique_edges = []
        seen_edges = set()
        for edge in graph.get("edges", []):
            u = node_id_map.get(edge["from"], edge["from"])
            v = node_id_map.get(edge["to"], edge["to"])
            if u != v:
                edge_tuple = (u, v)
                if edge_tuple not in seen_edges:
                    seen_edges.add(edge_tuple)
                    unique_edges.append({"from": u, "to": v})

        return {
            "nodes": unique_nodes,
            "edges": unique_edges,
            "meta": graph.get("meta", {}),
            "constraints": graph.get("constraints", {})
        }
