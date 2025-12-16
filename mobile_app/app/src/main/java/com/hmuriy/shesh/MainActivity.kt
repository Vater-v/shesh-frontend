package com.hmuriy.shesh

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.hmuriy.shesh.ui.navigation.SheshNavGraph
import com.hmuriy.shesh.ui.theme.SheshTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // 1. Установка Splash Screen.
        // Должно быть вызвано ДО super.onCreate().
        val splashScreen = installSplashScreen()

        super.onCreate(savedInstanceState)

        // 2. Включение режима Edge-to-Edge.
        // Контент (фон) рисуется под системными барами.
        // Безопасные отступы для элементов UI мы обрабатываем в самих экранах (например, через systemBarsPadding).
        enableEdgeToEdge()

        setContent {
            SheshTheme {
                // 3. Точка входа в навигацию.
                SheshNavGraph()
            }
        }
    }
}
