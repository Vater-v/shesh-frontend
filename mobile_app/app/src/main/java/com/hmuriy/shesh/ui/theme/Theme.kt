//./ui/theme/Theme.kt
package com.hmuriy.shesh.ui.theme

import android.app.Activity
import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.font.FontFamily
import androidx.core.view.WindowCompat

// Основная темная схема "Mastery Mode"
private val DarkColorScheme = darkColorScheme(
    primary = CyberCyan,
    onPrimary = Color.Black,
    primaryContainer = SurfaceGunmetal,
    onPrimaryContainer = CyberCyan,
    outline = CyberCyan,
    outlineVariant = TextGray,
    secondary = SoftViolet,
    onSecondary = TextWhite,
    secondaryContainer = DeepViolet,
    onSecondaryContainer = TextWhite,
    tertiary = TerminalGreen,
    background = VoidDark,
    onBackground = TextWhite,
    surface = SurfaceGunmetal,
    onSurface = TextWhite,
    surfaceVariant = SurfaceLighter,
    onSurfaceVariant = TextGray,
    error = CriticalRed,
    onError = Color.White,
)

@Composable
fun SheshTheme(
    darkTheme: Boolean = true, // Force Dark Theme for Cyberpunk feel
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit
) {
    val colorScheme = DarkColorScheme

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            // Полная прозрачность
            window.statusBarColor = Color.Transparent.toArgb()
            window.navigationBarColor = VoidDark.toArgb()

            val insetsController = WindowCompat.getInsetsController(window, view)
            insetsController.isAppearanceLightStatusBars = false
            insetsController.isAppearanceLightNavigationBars = false
        }
    }

    // Переопределяем типографику на Monospace глобально
    val defaultTypography = Typography()
    val terminalTypography = Typography(
        displayLarge = defaultTypography.displayLarge.copy(fontFamily = FontFamily.Monospace),
        displayMedium = defaultTypography.displayMedium.copy(fontFamily = FontFamily.Monospace),
        displaySmall = defaultTypography.displaySmall.copy(fontFamily = FontFamily.Monospace),
        headlineLarge = defaultTypography.headlineLarge.copy(fontFamily = FontFamily.Monospace),
        headlineMedium = defaultTypography.headlineMedium.copy(fontFamily = FontFamily.Monospace),
        headlineSmall = defaultTypography.headlineSmall.copy(fontFamily = FontFamily.Monospace),
        titleLarge = defaultTypography.titleLarge.copy(fontFamily = FontFamily.Monospace),
        titleMedium = defaultTypography.titleMedium.copy(fontFamily = FontFamily.Monospace),
        titleSmall = defaultTypography.titleSmall.copy(fontFamily = FontFamily.Monospace),
        bodyLarge = defaultTypography.bodyLarge.copy(fontFamily = FontFamily.Monospace),
        bodyMedium = defaultTypography.bodyMedium.copy(fontFamily = FontFamily.Monospace),
        bodySmall = defaultTypography.bodySmall.copy(fontFamily = FontFamily.Monospace),
        labelLarge = defaultTypography.labelLarge.copy(fontFamily = FontFamily.Monospace),
        labelMedium = defaultTypography.labelMedium.copy(fontFamily = FontFamily.Monospace),
        labelSmall = defaultTypography.labelSmall.copy(fontFamily = FontFamily.Monospace)
    )

    MaterialTheme(
        colorScheme = colorScheme,
        typography = terminalTypography,
        content = content
    )
}
