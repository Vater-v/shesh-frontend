//./ui/navigation/SheshNavGraph.kt
package com.hmuriy.shesh.ui.navigation

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.hmuriy.shesh.ui.login.LoginScreen
import com.hmuriy.shesh.ui.welcome.WelcomeScreen

sealed class Screen(val route: String) {
    data object Welcome : Screen("welcome")
    data object RegisterEmail : Screen("register_email")
    data object Login : Screen("login")
    data object Home : Screen("home") // Заглушка главного экрана
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
        modifier = modifier
    ) {
        // --- Лендинг ---
        composable(Screen.Welcome.route) {
            WelcomeScreen(
                onLoginClick = { navController.navigate(Screen.Login.route) },
                onRegisterClick = { navController.navigate(Screen.RegisterEmail.route) },
                onThemeToggle = onThemeToggle,
                isDarkTheme = isDarkTheme
            )
        }

        // --- Вход ---
        composable(Screen.Login.route) {
            LoginScreen(
                onBackClick = { navController.popBackStack() },
                onLoginSuccess = {
                    // Переход на Home и удаление истории входа
                    navController.navigate(Screen.Home.route) {
                        popUpTo(Screen.Welcome.route) { inclusive = true }
                    }
                }
            )
        }

        // --- Регистрация (Заглушка) ---
        composable(Screen.RegisterEmail.route) {
            // TODO: Создайте RegisterScreen по аналогии с LoginScreen
            Text("Экран регистрации", color = androidx.compose.ui.graphics.Color.White)
        }

        // --- Главный экран (Заглушка) ---
        composable(Screen.Home.route) {
            Text("Добро пожаловать!", color = androidx.compose.ui.graphics.Color.White)
        }
    }
}
