package com.hmuriy.shesh.ui

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.RectangleShape
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.hmuriy.shesh.ui.theme.*
import androidx.compose.foundation.background
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.graphics.Color
import androidx.compose.material3.Button
import androidx.compose.ui.res.painterResource

@Composable
fun WelcomeScreen(
    onGoogleSignUpClick: () -> Unit,
    onLoginSignUpClick: () -> Unit,
    onSignInClick: () -> Unit
) {
    // Scaffold или Surface обеспечивает правильный фон и цвет контента
    Surface(
        modifier = Modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.background
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                // Учитываем системные отступы (status bar, nav bar), чтобы контент не перекрывался
                .systemBarsPadding()
                .padding(horizontal = 24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {

            // --- БЛОК БРЕНДИНГА ---
            // Используем weight, чтобы логотип был визуально выше центра, но плавал при изменении экрана
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.Center,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "SHESH",
                    style = MaterialTheme.typography.displayLarge.copy(
                        fontWeight = FontWeight.Black,
                        color = MaterialTheme.colorScheme.primary
                    )
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "Make it Shesh",
                    style = MaterialTheme.typography.headlineSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            // --- БЛОК ДЕЙСТВИЙ ---
            // Нижняя часть экрана с кнопками
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 32.dp), // Отступ от нижнего края (над навигацией)
                verticalArrangement = Arrangement.spacedBy(12.dp), // Единый отступ между элементами
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // PRIMARY ACTION: Самое желаемое действие (Google)
                // Выделяем цветом, добавляем иконку для узнаваемости
                Button(
                    onClick = onGoogleSignUpClick,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp),
                    shape = MaterialTheme.shapes.medium
                ) {
                    //  - обычно здесь Icon
                    Icon(
                        painter = painterResource(id = android.R.drawable.ic_menu_add), // Заглушка
                        contentDescription = null,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Продолжить через Google")
                }

                // SECONDARY ACTION: Альтернатива
                // Используем Outlined или Tonal Button, чтобы снизить визуальный шум.
                // Если все кнопки "жирные", глаз теряется.
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

                // TERTIARY ACTION: Вход для существующих
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
