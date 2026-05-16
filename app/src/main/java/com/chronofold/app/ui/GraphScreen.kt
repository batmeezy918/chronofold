package com.chronofold.app.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.chronofold.app.compiler.GraphToComposeCompiler

@Composable
fun GraphScreen() {
    val context = LocalContext.current
    val compiler = remember { GraphToComposeCompiler(context) }
    val operators = remember { compiler.compile() }

    Column(modifier = Modifier.padding(16.dp)) {
        Text("GRAPH EXECUTION VIEW", style = MaterialTheme.typography.headlineMedium)
        Text("Operators derived from workflow_graph.json:", modifier = Modifier.padding(bottom = 8.dp))

        LazyColumn {
            items(operators) { op ->
                Card(
                    modifier = Modifier.padding(vertical = 4.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(text = "ID: ${op.id}", style = MaterialTheme.typography.titleMedium)
                        Text(text = "Role: ${op.role}", style = MaterialTheme.typography.bodyMedium)
                    }
                }
            }
        }
    }
}
