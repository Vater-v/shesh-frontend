//./ui/theme/Theme.kt
package com.hmuriy.shesh.ui.theme

import android.app.Activity
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.font.FontFamily
import androidx.core.view.WindowCompat

// --- Dark Scheme (Hacker Mode) ---
private val DarkColorScheme = darkColorScheme(
    primary = CyberCyan,
    onPrimary = Color.Black,
    primaryContainer = SurfaceGunmetal,
    onPrimaryContainer = CyberCyan,
    secondary = SoftViolet,
    onSecondary = TextWhite,
    background = VoidDark,
    onBackground = TextWhite,
    surface = SurfaceGunmetal,
    onSurface = TextWhite,
    surfaceVariant = SurfaceLighter,
    onSurfaceVariant = TextGray,
    error = CriticalRed,
    outline = CyberCyan // Neon borders
)

// --- Light Scheme (Corporate Mode) ---
private val LightColorScheme = lightColorScheme(
    primary = DeepViolet, // High contrast violet for light mode
    onPrimary = Color.White,
    primaryContainer = Color(0xFFEDE7F6),
    onPrimaryContainer = DeepViolet,
    secondary = CyberCyanDark,
    onSecondary = Color.White,
    background = CorpWhite,
    onBackground = TextCorpDark,
    surface = CorpSurface,
    onSurface = TextCorpDark,
    surfaceVariant = Color(0xFFEFEFEF),
    onSurfaceVariant = TextCorpGray,
    error = CriticalRed,
    outline = TextCorpGray // Strict borders
)

@Composable
fun SheshTheme(
    darkTheme: Boolean = true,
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit
) {
    // Select scheme based on state
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            // Transparent status bar
            window.statusBarColor = Color.Transparent.toArgb()
            // Match navigation bar with background
            window.navigationBarColor = colorScheme.background.toArgb()

            val insetsController = WindowCompat.getInsetsController(window, view)
            // Light icons for Dark Theme, Dark icons for Light Theme
            insetsController.isAppearanceLightStatusBars = !darkTheme
            insetsController.isAppearanceLightNavigationBars = !darkTheme
        }
    }

    // Force Monospace Typography for the "Terminal" feel
    val defaultTypography = Typography()
    val terminalTypography = Typography(
        displayLarge = defaultTypography.displayLarge.copy(fontFamily = FontFamily.Monospace),
        displayMedium = defaultTypography.displayMedium.copy(fontFamily = FontFamily.Monospace),
        headlineLarge = defaultTypography.headlineLarge.copy(fontFamily = FontFamily.Monospace),
        headlineMedium = defaultTypography.headlineMedium.copy(fontFamily = FontFamily.Monospace),
        titleLarge = defaultTypography.titleLarge.copy(fontFamily = FontFamily.Monospace),
        titleMedium = defaultTypography.titleMedium.copy(fontFamily = FontFamily.Monospace),
        bodyLarge = defaultTypography.bodyLarge.copy(fontFamily = FontFamily.Monospace),
        bodyMedium = defaultTypography.bodyMedium.copy(fontFamily = FontFamily.Monospace),
        labelLarge = defaultTypography.labelLarge.copy(fontFamily = FontFamily.Monospace)
    )

    MaterialTheme(
        colorScheme = colorScheme,
        typography = terminalTypography,
        content = content
    )
}
