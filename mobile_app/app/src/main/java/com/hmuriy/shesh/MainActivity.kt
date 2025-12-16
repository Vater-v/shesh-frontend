package com.hmuriy.shesh

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.hmuriy.shesh.ui.WelcomeScreen
import com.hmuriy.shesh.ui.theme.SheshTheme
import androidx.activity.enableEdgeToEdge

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {

        enableEdgeToEdge()


        val splashScreen = installSplashScreen()

        var isReady = false
        splashScreen.setKeepOnScreenCondition {
            !isReady
        }
        super.onCreate(savedInstanceState)

        setContent {
            SheshTheme {
                isReady = true
                WelcomeScreen()
            }
        }
    }
}
