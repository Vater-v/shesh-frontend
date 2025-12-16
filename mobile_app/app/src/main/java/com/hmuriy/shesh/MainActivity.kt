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
        // Это связывает тему Theme.App.Starting (из themes.xml) с логикой запуска.
        val splashScreen = installSplashScreen()

        // Опционально: если нужно удержать сплэш (например, пока идет загрузка данных):
        // splashScreen.setKeepOnScreenCondition { viewModel.isLoading.value }

        super.onCreate(savedInstanceState)

        // 2. Включение режима Edge-to-Edge.
        // Это позволяет контенту (вашему темному фону VoidDark) рисоваться ПОД
        // статус-баром и навигационной панелью.
        // В Theme.kt у вас уже есть логика, делающая бары прозрачными,
        // enableEdgeToEdge() необходим, чтобы система разрешила это наложение.
        enableEdgeToEdge()

        setContent {
            // 3. Применение вашей темы.
            // В файле Theme.kt (строки 42-62) у вас прописана логика SideEffect,
            // которая управляет цветом иконок статус-бара (светлые/темные).
            SheshTheme {
                // 4. Точка входа в навигацию.
                // MainActivity не должна знать про экраны (Welcome, Login),
                // она просто запускает "Граф навигации".
                SheshNavGraph()
            }
        }
    }
}
