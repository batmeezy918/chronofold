import os

class Emitter:
    """Deterministic Kotlin/Compose Code Emitter"""
    def emit_compose_screen(self, node):
        return f"""
package com.apollo.generated

import androidx.compose.material.Text
import androidx.compose.runtime.Composable

@Composable
fun {node['id']}Screen() {{
    Text("Generated Node: {node['id']}")
}}
"""

    def generate_project(self, graph, output_dir):
        os.makedirs(output_dir, exist_ok=True)
        gen_dir = os.path.join(output_dir, "src/main/java/com/apollo/generated")
        os.makedirs(gen_dir, exist_ok=True)

        for node in graph["nodes"]:
            if node.get("type") == "ui":
                content = self.emit_compose_screen(node)
                with open(os.path.join(gen_dir, f"{node['id']}Screen.kt"), "w") as f:
                    f.write(content)

        print(f"Project generated at {output_dir}")
