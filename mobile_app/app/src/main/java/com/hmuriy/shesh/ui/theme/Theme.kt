package com.hmuriy.shesh.ui.theme

import android.app.Activity
import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

// --- SHESH COLOR PALETTE ---

// Primary & Brand (Неон)
val SheshCyan = Color(0xFF00F0FF)
val SheshMagenta = Color(0xFFBC13FE)
val AcidGreen = Color(0xFF39FF14)

// Backgrounds (Глубина)
val DeepVoid = Color(0xFF0B0B15)
val NightShade = Color(0xFF1A1A2E)

// Text & UI
val HoloWhite = Color(0xFFFFFFFF)
val TechGrey = Color(0xFF8F9BB3)
val ErrorRed = Color(0xFFFF0033)

// --- MATERIAL 3 COLOR SCHEMES ---

private val DarkColorScheme = darkColorScheme(
    primary = SheshCyan,
    onPrimary = DeepVoid,
    primaryContainer = NightShade,
    onPrimaryContainer = SheshCyan,

    secondary = SheshMagenta,
    onSecondary = HoloWhite,
    secondaryContainer = SheshMagenta.copy(alpha = 0.2f),
    onSecondaryContainer = SheshMagenta,

    tertiary = AcidGreen,
    onTertiary = DeepVoid,

    background = DeepVoid,
    onBackground = HoloWhite,

    surface = NightShade,
    onSurface = HoloWhite,
    surfaceVariant = NightShade,
    onSurfaceVariant = TechGrey,

    error = ErrorRed,
    onError = HoloWhite
)

private val LightColorScheme = lightColorScheme(
    primary = SheshCyan,
    onPrimary = HoloWhite,
    secondary = SheshMagenta,
    background = Color(0xFFF0F2F5),
    surface = Color.White,
    onBackground = DeepVoid,
    onSurface = DeepVoid
)

@Composable
fun SheshTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }
        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.background.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = !darkTheme
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        // typography = Typography, // Раскомментируй, когда создашь файл Type.kt
        content = content
    )
}
