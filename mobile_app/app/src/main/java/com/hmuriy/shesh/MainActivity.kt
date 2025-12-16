package com.hmuriy.shesh

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Вызвать ДО super.onCreate
        val splashScreen = installSplashScreen()

        super.onCreate(savedInstanceState)

        // Опционально: держать сплэш, пока грузятся данные (ViewModel)
        /*
        splashScreen.setKeepOnScreenCondition {
            viewModel.isLoading.value // Возвращать true, пока грузится
        }
        */

        setContent {
            SheshTheme {
                // Сразу показывай WelcomeScreen или MainScreen
                WelcomeScreen()
            }
        }
    }
}
