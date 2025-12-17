//./ui/Theme.kt
package com.hmuriy.shesh.ui.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.unit.dp
import androidx.core.view.WindowCompat

private val LightColorScheme = lightColorScheme(
    primary = TechPrimary,
    onPrimary = Color.White,
    primaryContainer = Color(0xFFE3E5E8),
    onPrimaryContainer = TechPrimary,
    secondary = TechSecondary,
    onSecondary = Color.White,
    background = TechBackground,
    surface = TechSurface,
    onSurface = TechTextPrimary,
    onSurfaceVariant = TechTextSecondary,
    outline = TechOutline,
    error = TechAccent
)

private val DarkColorScheme = darkColorScheme(
    primary = VoidPrimary,
    onPrimary = Color.Black, // Black text on Cyan for max readability
    primaryContainer = Color(0xFF003E45),
    onPrimaryContainer = VoidPrimary,
    secondary = VoidSecondary,
    onSecondary = Color.White,
    background = VoidBackground,
    surface = VoidSurface,
    onSurface = VoidTextPrimary,
    onSurfaceVariant = VoidTextSecondary,
    outline = VoidOutline,
    error = VoidError
)

@Composable
fun SheshTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme
    val view = LocalView.current

    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            val insetsController = WindowCompat.getInsetsController(window, view)

            // Ensure status bars are transparent and icons adapt to theme
            insetsController.isAppearanceLightStatusBars = !darkTheme
            insetsController.isAppearanceLightNavigationBars = !darkTheme
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography(),
        shapes = Shapes(
            small = RoundedCornerShape(8.dp),   // Sharper, technical corners
            medium = RoundedCornerShape(12.dp),
            large = RoundedCornerShape(16.dp)
        ),
        content = content
    )
}
