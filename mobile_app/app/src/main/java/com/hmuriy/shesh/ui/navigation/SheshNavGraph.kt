package com.hmuriy.shesh.ui.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHost
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.hmuriy.shesh.ui.WelcomeScreen
//Здесь живет ваша навигация и реализация переходов
@Composable
fun SheshNavGraph() {
    val navController = rememberNavController()

    NavHost(navController = navController, startDestination = "welcome") {
        
        // Экран приветствия
        composable("welcome") {
            WelcomeScreen(
                onGoogleSignUpClick = {
                    // Тут может быть вызов ViewModel или сложная логика
                    // viewModel.startGoogleAuth() 
                },
                onLoginSignUpClick = {
                    // Простой переход на экран регистрации по Email
                    navController.navigate("register_email")
                },
                onSignInClick = {
                    // Переход на экран входа
                    navController.navigate("login")
                }
            )
        }

        // Другие экраны (заглушки для примера)
        composable("register_email") { /* Screen(...) */ }
        composable("login") { /* Screen(...) */ }
    }
}
