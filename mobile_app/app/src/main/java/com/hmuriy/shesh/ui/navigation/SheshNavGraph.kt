package com.hmuriy.shesh.ui.navigation

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.hmuriy.shesh.ui.welcome.WelcomeScreen
import com.hmuriy.shesh.ui.welcome.WelcomeUiState
import com.hmuriy.shesh.ui.welcome.WelcomeViewModel

// Импорты для новых экранов (раскомментируйте или создайте файлы, когда они появятся)
// import com.hmuriy.shesh.ui.login.LoginScreen
// import com.hmuriy.shesh.ui.register.RegisterScreen

/**
 * Определение маршрутов навигации.
 */
sealed class Screen(val route: String) {
    data object Welcome : Screen("welcome")
    data object RegisterEmail : Screen("register_email")
    data object Login : Screen("login")
}

@Composable
fun SheshNavGraph(
    modifier: Modifier = Modifier,
    navController: NavHostController = rememberNavController()
) {
    NavHost(
        navController = navController,
        startDestination = Screen.Welcome.route,
        modifier = modifier
    ) {
        // --- Экран приветствия ---
        composable(Screen.Welcome.route) {
            // Получаем ViewModel
            val viewModel: WelcomeViewModel = viewModel()

            // 1. Подписываемся на состояние UI
            val uiState by viewModel.uiState.collectAsState()

            // 2. Ловим событие успеха (Success) для навигации
            LaunchedEffect(uiState) {
                if (uiState is WelcomeUiState.Success) {
                    // При успешном входе переходим на следующий экран (например, Login или Home)
                    navController.navigate(Screen.Login.route) {
                        // Убираем Welcome из стека, чтобы нельзя было вернуться назад
                        popUpTo(Screen.Welcome.route) { inclusive = true }
                    }
                    viewModel.resetState()
                }
            }

            WelcomeScreen(
                // Связываем получение токена с логикой входа во ViewModel
                onGoogleSignInSuccess = { token ->
                    viewModel.handleGoogleSignIn(token)
                },
                onLoginSignUpClick = {
                    navController.navigate(Screen.RegisterEmail.route)
                },
                onSignInClick = {
                    navController.navigate(Screen.Login.route)
                }
            )
        }

        // --- Экран регистрации по Email ---
        composable(Screen.RegisterEmail.route) {
            // ВРЕМЕННАЯ ЗАГЛУШКА (замените на RegisterScreen когда создадите его)
            Text("Экран регистрации (создайте RegisterScreen.kt)")
        }

        // --- Экран входа ---
        composable(Screen.Login.route) {
            // ВРЕМЕННАЯ ЗАГЛУШКА (замените на LoginScreen когда создадите его)
            Text("Экран входа (создайте LoginScreen.kt)")
        }
    }
}
