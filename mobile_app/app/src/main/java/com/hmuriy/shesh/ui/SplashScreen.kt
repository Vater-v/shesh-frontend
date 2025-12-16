package com.hmuriy.shesh.ui

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import kotlinx.coroutines.delay
import com.hmuriy.shesh.ui.theme.SheshTheme

class SplashScreen : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            SheshTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    SplashScreenContent()
                }
            }
        }
    }
}

@Composable
fun SplashScreenContent() {
    var showWelcomeScreen by remember { mutableStateOf(false) }

    LaunchedEffect(key1 = true) {
        delay(2000) // Задержка 2 секунды (2000 миллисекунд)
        showWelcomeScreen = true
    }

    // Логика переключения экранов
    if (showWelcomeScreen) {
        WelcomeScreen() // Переход на WelcomeScreen
    } else {
        // Здесь ваш дизайн для Splash Screen (пока идет загрузка)
        Box(contentAlignment = Alignment.Center, modifier = Modifier.fillMaxSize()) {
            // Можно добавить логотип или текст "Загрузка..."
            // Например: Image(painter = painterResource(id = R.drawable.ic_launcher_foreground), contentDescription = null)
        }
    }
}
