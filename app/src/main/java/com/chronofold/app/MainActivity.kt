package com.chronofold.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import com.chronofold.app.compiler.GraphToComposeCompiler
import com.chronofold.app.navigation.NavGraph

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Compile the graph at startup
        GraphToComposeCompiler(this).compile()

        setContent {
            NavGraph()
        }
    }
}
