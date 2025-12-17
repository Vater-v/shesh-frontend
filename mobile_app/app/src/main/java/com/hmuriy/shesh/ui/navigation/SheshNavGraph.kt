//./ui/navigation/SheshNavGraph.kt
package com.hmuriy.shesh.ui.navigation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.hmuriy.shesh.ui.login.LoginScreen
import com.hmuriy.shesh.ui.register.RegisterScreen
import com.hmuriy.shesh.ui.theme.CyberCyan
import com.hmuriy.shesh.ui.theme.VoidDark
import com.hmuriy.shesh.ui.welcome.WelcomeScreen

sealed class Screen(val route: String) {
    data object Welcome : Screen("welcome")
    data object Register : Screen("register")
    data object Login : Screen("login")
    data object Home : Screen("home")
}

@Composable
fun SheshNavGraph(
    modifier: Modifier = Modifier,
    navController: NavHostController = rememberNavController(),
    onThemeToggle: () -> Unit,
    isDarkTheme: Boolean
) {
    NavHost(
        navController = navController,
        startDestination = Screen.Welcome.route,
        modifier = modifier.background(VoidDark)
    ) {
        // --- Landing ---
        composable(Screen.Welcome.route) {
            WelcomeScreen(
                onLoginClick = { navController.navigate(Screen.Login.route) },
                onRegisterClick = { navController.navigate(Screen.Register.route) },
                onThemeToggle = onThemeToggle,
                isDarkTheme = isDarkTheme
            )
        }

        // --- The Gateway (Login) ---
        composable(Screen.Login.route) {
            LoginScreen(
                onBackClick = { navController.popBackStack() },
                onLoginSuccess = {
                    navController.navigate(Screen.Home.route) {
                        popUpTo(Screen.Welcome.route) { inclusive = true }
                    }
                }
            )
        }

        // --- The Uplink (Registration) ---
        composable(Screen.Register.route) {
            RegisterScreen(
                onBackClick = { navController.popBackStack() },
                onRegisterSuccess = {
                    navController.navigate(Screen.Home.route) {
                        popUpTo(Screen.Welcome.route) { inclusive = true }
                    }
                }
            )
        }

        // --- Home (Stub) ---
        composable(Screen.Home.route) {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                Text("SYSTEM ONLINE. ACCESS GRANTED.", color = CyberCyan)
            }
        }
    }
}
