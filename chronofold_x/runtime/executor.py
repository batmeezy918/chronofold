class Executor:
    """Deterministic Workflow Executor"""
    def execute(self, graph):
        order = graph.get("execution_order", [])
        for node_id in order:
            print(f"Executing Node: {node_id}")
