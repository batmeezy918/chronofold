package com.chronofold.app.navigation

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Icon
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.List
import androidx.compose.material.icons.filled.Build
import androidx.compose.material.icons.filled.Info
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.chronofold.app.ui.HomeScreen
import com.chronofold.app.ui.TheoremScreen
import com.chronofold.app.ui.GraphScreen
import com.chronofold.app.ui.BuildScreen

sealed class Screen(val route: String, val label: String) {
    object Home : Screen("home", "Home")
    object Theorem : Screen("theorem", "Theorem")
    object Graph : Screen("graph", "Graph")
    object Build : Screen("build", "Build")
}

@Composable
fun NavGraph() {
    val navController = rememberNavController()
    val items = listOf(Screen.Home, Screen.Theorem, Screen.Graph, Screen.Build)

    Scaffold(
        bottomBar = {
            NavigationBar {
                val navBackStackEntry by navController.currentBackStackEntryAsState()
                val currentRoute = navBackStackEntry?.destination?.route
                items.forEach { screen ->
                    NavigationBarItem(
                        icon = {
                            when(screen) {
                                Screen.Home -> Icon(Icons.Filled.Home, contentDescription = null)
                                Screen.Theorem -> Icon(Icons.Filled.Info, contentDescription = null)
                                Screen.Graph -> Icon(Icons.Filled.List, contentDescription = null)
                                Screen.Build -> Icon(Icons.Filled.Build, contentDescription = null)
                            }
                        },
                        label = { Text(screen.label) },
                        selected = currentRoute == screen.route,
                        onClick = {
                            navController.navigate(screen.route) {
                                popUpTo(navController.graph.startDestinationId)
                                launchSingleTop = true
                            }
                        }
                    )
                }
            }
        }
    ) { innerPadding ->
        NavHost(navController, startDestination = Screen.Home.route, modifier = Modifier.padding(innerPadding)) {
            composable(Screen.Home.route) { HomeScreen() }
            composable(Screen.Theorem.route) { TheoremScreen() }
            composable(Screen.Graph.route) { GraphScreen() }
            composable(Screen.Build.route) { BuildScreen() }
        }
    }
}
