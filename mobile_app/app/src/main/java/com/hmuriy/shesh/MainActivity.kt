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
        val splashScreen = installSplashScreen()

        enableEdgeToEdge()

        super.onCreate(savedInstanceState)

        setContent {
            // 4. Применяем тему. Она обработает цвета статус-бара.
            SheshTheme {
                // 5. Запускаем граф навигации (вместо конкретного экрана)
                SheshNavGraph()
            }
        }
    }
}
