package com.hmuriy.shesh.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.hmuriy.shesh.ui.WelcomeScreen
import com.hmuriy.shesh.ui.welcome.WelcomeViewModel

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

            WelcomeScreen(
                onGoogleSignUpClick = {
                    // TODO: Реализовать логику через viewModel, например:
                    // viewModel.handleGoogleSignIn()
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
            // После создания замените на вызов реального экрана:
            /*
            RegisterScreen(
                onBackClick = { navController.popBackStack() },
                onRegisterSuccess = {
                    // Логика после успешной регистрации
                }
            )
            */
            // Удалите этот блок Text после создания реального экрана
            androidx.compose.material3.Text("Экран регистрации (создайте RegisterScreen.kt)")
        }

        // --- Экран входа ---
        composable(Screen.Login.route) {
            // ВРЕМЕННАЯ ЗАГЛУШКА (пока вы не создадите файл LoginScreen.kt)
            // После создания замените на вызов реального экрана:
            /*
            LoginScreen(
                onBackClick = { navController.popBackStack() },
                onLoginSuccess = {
                    // Логика после входа
                }
            )
            */
            // Удалите этот блок Text после создания реального экрана
            androidx.compose.material3.Text("Экран входа (создайте LoginScreen.kt)")
        }
    }
}
