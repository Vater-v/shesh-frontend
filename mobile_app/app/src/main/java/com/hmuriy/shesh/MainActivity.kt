package com.hmuriy.shesh

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels // <-- Добавить импорт
import androidx.compose.runtime.collectAsState // <-- Добавить импорт
import androidx.compose.runtime.getValue // <-- Добавить импорт
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.hmuriy.shesh.ui.navigation.SheshNavGraph
import com.hmuriy.shesh.ui.theme.SheshTheme

class MainActivity : ComponentActivity() {

    // Инициализируем ViewModel
    private val mainViewModel: MainViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        val splashScreen = installSplashScreen()
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            // 1. Подписываемся на состояние темы
            val isDarkTheme by mainViewModel.isDarkTheme.collectAsState()

            // 2. Передаем динамическое значение
            SheshTheme(
                darkTheme = isDarkTheme, // Теперь управляется через DataStore
                dynamicColor = false
            ) {
                // 3. Передаем функцию переключения и состояние в навигацию
                SheshNavGraph(
                    onThemeToggle = { mainViewModel.toggleTheme() },
                    isDarkTheme = isDarkTheme
                )
            }
        }
    }
}
