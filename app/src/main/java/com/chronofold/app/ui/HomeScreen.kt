package com.chronofold.app.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun HomeScreen() {
    Column(modifier = Modifier.padding(16.dp)) {
        Text("HOME DASHBOARD", style = MaterialTheme.typography.headlineMedium)
        Text("System Status: ACTIVE", style = MaterialTheme.typography.bodyLarge)
        Text("Current Workflow State ψ: ψ_k", style = MaterialTheme.typography.bodyLarge)
        Text("Last Execution Result: SUCCESS", style = MaterialTheme.typography.bodyLarge)
    }
}
