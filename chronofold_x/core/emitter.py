import os

class Emitter:
    """Deterministic Kotlin/Compose Code Emitter"""

    def emit_compose_screen(self, node):
        return f"""
package com.apollo.generated.ui

import androidx.compose.runtime.Composable
import androidx.compose.material.Text
import com.apollo.generated.viewmodel.{node['id']}ViewModel

@Composable
fun {node['id']}Screen(viewModel: {node['id']}ViewModel) {{
    Text("UI for {node['id']}")
}}
"""

    def emit_view_model(self, node):
        return f"""
package com.apollo.generated.viewmodel

import androidx.lifecycle.ViewModel

class {node['id']}ViewModel : ViewModel() {{
    // Logic for {node['id']}
}}
"""

    def emit_repository(self, node):
        return f"""
package com.apollo.generated.repository

class {node['id']}Repository {{
    // Data operations for {node['id']}
}}
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

        # Build configuration (Kotlin DSL)
        with open(os.path.join(output_dir, "build.gradle.kts"), "w") as f:
            f.write("""
buildscript {
    repositories { google(); mavenCentral() }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
    }
}
allprojects { repositories { google(); mavenCentral() } }
""")

        with open(os.path.join(output_dir, "settings.gradle.kts"), "w") as f:
            f.write("rootProject.name = \"GeneratedApp\"\ninclude(\":app\")\n")

        os.makedirs(os.path.join(output_dir, "app"), exist_ok=True)
        with open(os.path.join(output_dir, "app/build.gradle.kts"), "w") as f:
            f.write("""
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}
android {
    namespace = "com.apollo.generated"
    compileSdk = 34
    buildFeatures { compose = true }
    composeOptions { kotlinCompilerExtensionVersion = "1.5.8" }
}
dependencies {
    implementation("androidx.compose.ui:ui:1.6.1")
    implementation("androidx.compose.material:material:1.6.1")
}
""")
