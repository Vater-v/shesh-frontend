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

// Основная темная схема "Mastery Mode"
private val DarkColorScheme = darkColorScheme(
    primary = CyberCyan,
    onPrimary = Color.Black, // Черный текст на циане читается лучше всего
    primaryContainer = SurfaceGunmetal,
    onPrimaryContainer = CyberCyan,
    outline = CyberCyan,
    outlineVariant = TextGray,
    secondary = SoftViolet,
    onSecondary = TextWhite,
    secondaryContainer = DeepViolet,
    onSecondaryContainer = TextWhite,

    tertiary = TerminalGreen, // Используем для статусов "Active"

    background = VoidDark,
    onBackground = TextWhite,

    surface = SurfaceGunmetal,
    onSurface = TextWhite,
    surfaceVariant = SurfaceLighter,
    onSurfaceVariant = TextGray,

    error = CriticalRed,
    onError = Color.White,

)

// Светлая схема (Fallback, если пользователю очень нужно, но лучше форсировать темную)
private val LightColorScheme = lightColorScheme(
    primary = CyberCyanDark,
    onPrimary = Color.White,
    primaryContainer = Color(0xFFE0F7FA),

    background = Color(0xFFF5F5F5),
    surface = Color.White,
    onSurface = Color(0xFF1C222E), // Темно-серый текст

    // ... остальные цвета можно адаптировать
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

            // --- ИЗМЕНЕНИЯ ЗДЕСЬ ---
            // Делаем статус-бар прозрачным.
            // Теперь цвет фона (VoidDark из Scaffold/Surface) будет виден сквозь него.
            window.statusBarColor = Color.Transparent.toArgb()

            // Навигационный бар тоже часто делают прозрачным для полного Edge-to-Edge,
            // либо оставляют залитым цветом фона (как у вас было).
            // Если хотите, чтобы контент заезжал и под кнопки навигации, ставьте Transparent.
            window.navigationBarColor = colorScheme.background.toArgb()
            // -----------------------

            // Управляем цветом иконок (светлые/темные)
            val insetsController = WindowCompat.getInsetsController(window, view)
            insetsController.isAppearanceLightStatusBars = !darkTheme
            insetsController.isAppearanceLightNavigationBars = !darkTheme
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        // typography = Typography,
        content = content
    )
}
