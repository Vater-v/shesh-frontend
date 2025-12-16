package com.hmuriy.shesh.ui.navigation

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
import androidx.compose.material3.Text

// Импорты для новых экранов (раскомментируйте или создайте файлы, если их нет)
// import com.hmuriy.shesh.ui.login.LoginScreen
// import com.hmuriy.shesh.ui.register.RegisterScreen

/**
 * Определение маршрутов навигации.
 * Можно вынести в отдельный файл Screen.kt, но для удобства оставлено здесь.
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
            // Получаем ViewModel (инстанс сохраняется при пересоздании активити)
            val viewModel: WelcomeViewModel = viewModel()

            // 1. Подписываемся на состояние UI
            val uiState by viewModel.uiState.collectAsState()

            // 2. Ловим событие успеха (Success) для навигации
            // LaunchedEffect перезапускается каждый раз, когда меняется uiState
            LaunchedEffect(uiState) {
                if (uiState is WelcomeUiState.Success) {
                    // При успешном входе через Google переходим, например, на экран Логина
                    // или на Главный экран (если он уже есть)
                    navController.navigate(Screen.Login.route) {
                        // Опционально: очистить стек, чтобы нельзя было вернуться назад на Welcome
                        // popUpTo(Screen.Welcome.route) { inclusive = true }
                    }
                    viewModel.resetState()
                }
            }

            WelcomeScreen(
                // Если захотите передать состояние загрузки в WelcomeScreen для спиннера:
                // state = uiState,
                onGoogleSignUpClick = {
                    // Запускаем логику входа во ViewModel
                    viewModel.handleGoogleSignIn()
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
            // ВРЕМЕННАЯ ЗАГЛУШКА (пока вы не создадите файл RegisterScreen.kt)
            /*
            RegisterScreen(
                onBackClick = { navController.popBackStack() },
                onRegisterSuccess = {
                    // Логика после успешной регистрации
                }
            )
            */
            Text("Экран регистрации (создайте RegisterScreen.kt)")
        }

        // --- Экран входа ---
        composable(Screen.Login.route) {
            // ВРЕМЕННАЯ ЗАГЛУШКА (пока вы не создадите файл LoginScreen.kt)
            /*
            LoginScreen(
                onBackClick = { navController.popBackStack() },
                onLoginSuccess = {
                    // Логика после входа
                }
            )
            */
            Text("Экран входа (создайте LoginScreen.kt)")
        }
    }
}
