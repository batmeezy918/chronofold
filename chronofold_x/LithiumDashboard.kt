package chronofold_x.ui.lithium

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

data class TheoremStatus(
    val id: String,
    val title: String,
    val status: String, // "verified_by_lean", "pending", "failed"
    val errors: Int = 0
)

@Composable
fun LithiumDashboard(theorems: List<TheoremStatus>) {
    Scaffold(
        topBar = {
            TopAppBar(title = { Text("Lithium Improver: AGD Dashboard") })
        }
    ) { padding ->
        Column(modifier = Modifier.padding(padding).fillMaxSize()) {
            StatsCard(theorems)
            Divider()
            TheoremList(theorems)
        }
    }
}

@Composable
fun StatsCard(theorems: List<TheoremStatus>) {
    val verified = theorems.count { it.status == "verified_by_lean" }
    Card(modifier = Modifier.padding(16.dp).fillMaxWidth(), elevation = 4.dp) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text("System Health: 0 Stars, 0 Errors", style = MaterialTheme.typography.h6)
            Text("Verified Theorems: $verified / ${theorems.size}")
            LinearProgressIndicator(
                progress = verified.toFloat() / theorems.size,
                modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
                color = Color.Green
            )
        }
    }
}

@Composable
fun TheoremList(theorems: List<TheoremStatus>) {
    LazyColumn {
        items(theorems) { thm ->
            TheoremItem(thm)
        }
    }
}

@Composable
fun TheoremItem(thm: TheoremStatus) {
    ListItem(
        text = { Text("${thm.id}: ${thm.title}") },
        secondaryText = { Text("Status: ${thm.status}") },
        trailing = {
            val color = if (thm.status == "verified_by_lean") Color.Green else Color.Red
            Icon(
                imageVector = if (thm.status == "verified_by_lean") Icons.Default.CheckCircle else Icons.Default.Error,
                contentDescription = null,
                tint = color
            )
        }
    )
}
