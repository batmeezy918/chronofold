import os

class Emitter:
    """Deterministic Kotlin/Compose Code Emitter"""

    def _read_template(self, name, **kwargs):
        tpl_path = os.path.join("templates", f"{name}.kt.tpl")
        if os.path.exists(tpl_path):
            with open(tpl_path, "r") as f:
                content = f.read()
            for k, v in kwargs.items():
                content = content.replace(f"{{{{{k}}}}}", str(v))
            return content
        return None

    def emit_compose_screen(self, node):
        tpl = self._read_template("compose_screen", node_id=node['id'])
        if tpl: return tpl
        return f"""
package com.apollo.generated.ui
import androidx.compose.runtime.Composable
import androidx.compose.material.Text
@Composable
fun {node['id']}Screen() {{ Text("UI for {node['id']}") }}
"""

    def emit_view_model(self, node):
        tpl = self._read_template("viewmodel", node_id=node['id'])
        if tpl: return tpl
        return f"""
package com.apollo.generated.viewmodel
import androidx.lifecycle.ViewModel
class {node['id']}ViewModel : ViewModel() {{ }}
"""

    def emit_repository(self, node):
        tpl = self._read_template("repository", node_id=node['id'])
        if tpl: return tpl
        return f"""
package com.apollo.generated.repository
class {node['id']}Repository {{ }}
"""

    def generate_project(self, graph, output_dir):
        os.makedirs(output_dir, exist_ok=True)
        base_pkg = os.path.join(output_dir, "app/src/main/java/com/apollo/generated")
        for sub in ["ui", "viewmodel", "repository"]:
            os.makedirs(os.path.join(base_pkg, sub), exist_ok=True)
        for node in graph["nodes"]:
            t = node.get("type")
            if t == "ui":
                with open(os.path.join(base_pkg, "ui", f"{node['id']}Screen.kt"), "w") as f:
                    f.write(self.emit_compose_screen(node))
            elif t == "logic":
                with open(os.path.join(base_pkg, "viewmodel", f"{node['id']}ViewModel.kt"), "w") as f:
                    f.write(self.emit_view_model(node))
            elif t == "data":
                with open(os.path.join(base_pkg, "repository", f"{node['id']}Repository.kt"), "w") as f:
                    f.write(self.emit_repository(node))
