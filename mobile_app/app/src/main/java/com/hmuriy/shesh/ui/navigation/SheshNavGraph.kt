package com.hmuriy.shesh.ui.navigation

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
import com.hmuriy.shesh.ui.WelcomeScreen

// Определение маршрутов (лучше вынести в отдельный файл Screen.kt в будущем)
sealed class Screen(val route: String) {
    data object Welcome : Screen("welcome")
    data object RegisterEmail : Screen("register_email")
    data object Login : Screen("login")
}

@Composable
fun SheshNavGraph(
    navController: NavHostController = rememberNavController()
) {
    NavHost(
        navController = navController,
        startDestination = Screen.Welcome.route
    ) {

        // Экран приветствия
        composable(Screen.Welcome.route) {
            WelcomeScreen(
                onGoogleSignUpClick = {
                    // TODO: Реализовать логику Google Auth
                },
                onLoginSignUpClick = {
                    navController.navigate(Screen.RegisterEmail.route)
                },
                onSignInClick = {
                    navController.navigate(Screen.Login.route)
                }
            )
        }

        // Экран регистрации по Email
        composable(Screen.RegisterEmail.route) {
            RegisterEmailScreen()
        }

        // Экран входа
        composable(Screen.Login.route) {
            LoginScreen()
        }
    }
}

// --- Временные заглушки для экранов (пока вы их не создали реально) ---

@Composable
fun RegisterEmailScreen() {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text(text = "Screen: Register Email")
    }
}

@Composable
fun LoginScreen() {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text(text = "Screen: Login")
    }
}
