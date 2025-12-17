//./MainActivity.kt
package com.hmuriy.shesh

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.hmuriy.shesh.ui.navigation.SheshNavGraph
import com.hmuriy.shesh.ui.theme.SheshTheme

class MainActivity : ComponentActivity() {

    // ViewModel scoped to the Activity to hold global state (Theme)
    private val mainViewModel: MainViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        val splashScreen = installSplashScreen()
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            // 1. Observe Theme State (persisted in DataStore)
            val isDarkTheme by mainViewModel.isDarkTheme.collectAsState()

            // 2. Apply Theme Wrapper
            SheshTheme(
                darkTheme = isDarkTheme,
                dynamicColor = false // Disable Material You to enforce Brand Colors
            ) {
                // 3. Pass toggle function and state to Navigation
                SheshNavGraph(
                    onThemeToggle = { mainViewModel.toggleTheme() },
                    isDarkTheme = isDarkTheme
                )
            }
        }
    }
}
