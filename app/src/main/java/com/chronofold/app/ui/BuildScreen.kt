package com.chronofold.app.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.Button
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun BuildScreen() {
    Column(modifier = Modifier.padding(16.dp)) {
        Text("BUILD & ARTIFACT VIEW", style = MaterialTheme.typography.headlineMedium)
        Button(onClick = { /* Trigger GitHub Action */ }, modifier = Modifier.padding(vertical = 8.dp)) {
            Text("Trigger Build")
        }
        Text("GitHub Actions Status: RUNNING", style = MaterialTheme.typography.bodyLarge)
        Text("APK Artifact: app-debug.apk", style = MaterialTheme.typography.bodyLarge, color = MaterialTheme.colorScheme.primary)
    }
}
