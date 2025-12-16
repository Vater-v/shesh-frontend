package com.hmuriy.shesh.ui.theme

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.hmuriy.shesh.ui.WelcomeScreen


class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Вызвать ДО super.onCreate
        val splashScreen = installSplashScreen()

        super.onCreate(savedInstanceState)

        setContent {
            // Если SheshTheme не существует, используйте MaterialTheme
            SheshTheme {
//            MaterialTheme {
                // Сразу показывай WelcomeScreen или MainScreen
                WelcomeScreen()
            }
        }
    }
}
