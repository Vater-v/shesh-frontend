package com.hmuriy.shesh.ui

import androidx.compose.animation.core.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.TileMode
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.hmuriy.shesh.ui.theme.*
import com.hmuriy.shesh.R

/**
 * Функция для создания анимированной кисти (эффект перелива).
 * Цвета циклично перетекают, создавая эффект "жидкого неона".
 * Исправлено: Размеры привязаны к Density (dp), чтобы корректно отображаться на разных экранах.
 */
@Composable
fun rememberAnimatedBrush(): Brush {
    val density = LocalDensity.current

    // Вычисляем размеры в пикселях на основе DP
    // distancePx - насколько далеко уходит градиент (длина цикла)
    // gradientWidthPx - физическая ширина самой цветовой полосы
    val (distancePx, gradientWidthPx) = with(density) {
        Pair(3000.dp.toPx(), 500.dp.toPx())
    }

    // 1. Определяем цвета для перелива.
    val shimmerColors = listOf(
        CyberCyan,          // Начало
        DeepViolet,         // Глубина
        Color(0xFFBC13FE),  // Яркая вспышка (Magenta)
        CyberCyan           // Конец (замыкаем круг)
    )

    // 2. Настраиваем бесконечную анимацию
    val transition = rememberInfiniteTransition(label = "shimmer_transition")

    // Анимируем значение смещения (offset)
    val translateAnimation by transition.animateFloat(
        initialValue = 0f,
        targetValue = distancePx, // Используем вычисленное значение (зависит от DPI)
        animationSpec = infiniteRepeatable(
            animation = tween(
                durationMillis = 12000,
                easing = LinearEasing
            ),
            repeatMode = RepeatMode.Restart
        ),
        label = "shimmer_offset"
    )

    // 3. Создаем градиент, который сдвигается по диагонали
    return Brush.linearGradient(
        colors = shimmerColors,
        start = Offset(translateAnimation, translateAnimation),
        // Ширина градиента теперь тоже зависит от DPI, сохраняя пропорции
        end = Offset(translateAnimation + gradientWidthPx, translateAnimation + gradientWidthPx),
        tileMode = TileMode.Mirror
    )
}

@Composable
fun WelcomeScreen(
    onGoogleSignUpClick: () -> Unit = {},
    onLoginSignUpClick: () -> Unit = {},
    onSignInClick: () -> Unit = {}
) {
    // Scaffold или Surface обеспечивает правильный фон и цвет контента
    Surface(
        modifier = Modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.background
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                // Учитываем системные отступы (status bar, nav bar)
                .systemBarsPadding()
                .padding(horizontal = 24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {

            // --- БЛОК БРЕНДИНГА ---
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.Center,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Получаем нашу анимированную кисть
                val animatedBrush = rememberAnimatedBrush()

                Text(
                    text = "SHESH",
                    style = MaterialTheme.typography.displayLarge.copy(
                        fontWeight = FontWeight.Black,
                        // Применяем "жидкий неон" вместо статического цвета
                        brush = animatedBrush
                    )
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "Make it Shesh",
                    style = MaterialTheme.typography.headlineSmall,
                    color = MaterialTheme.colorScheme.secondary
                )
            }

            // --- БЛОК ДЕЙСТВИЙ ---
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 32.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // PRIMARY ACTION: Google
                Button(
                    onClick = onGoogleSignUpClick,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp),
                    shape = MaterialTheme.shapes.medium
                ) {
                    Icon(
                        // Ссылаемся на созданный файл
                        painter = painterResource(id = R.drawable.ic_google_logo),
                        contentDescription = "Google Logo",
                        // Размер чуть больше, чем у стандартных иконок, для логотипов это нормально
                        modifier = Modifier.size(24.dp),
                        // ВАЖНО: Unspecified, чтобы Compose не перекрашивал иконку в цвет текста
                        tint = Color.Unspecified
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Продолжить через Google")
                }
                // SECONDARY ACTION: Email
                OutlinedButton(
                    onClick = onLoginSignUpClick,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp),
                    shape = MaterialTheme.shapes.medium,
                    border = BorderStroke(1.dp, MaterialTheme.colorScheme.outline)
                ) {
                    Text("Регистрация по email")
                }

                // TERTIARY ACTION: Вход
                TextButton(
                    onClick = onSignInClick,
                    modifier = Modifier.padding(top = 8.dp)
                ) {
                    Text(
                        text = "Уже есть аккаунт? ",
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = "Войти",
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.primary
                    )
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun WelcomeScreenPreview() {
    SheshTheme {
        WelcomeScreen()
    }
}
