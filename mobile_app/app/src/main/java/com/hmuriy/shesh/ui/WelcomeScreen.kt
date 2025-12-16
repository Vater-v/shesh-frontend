package com.hmuriy.shesh.ui

import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
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

@Composable
fun WelcomeScreen() {
    Column(
        modifier = Modifier.fillMaxSize() // Заполняем весь экран
    ) {
        // --- ВЕРХНЯЯ ЧЕТВЕРТЬ (Заголовок) ---
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f), // Занимает 1 часть из 4 (25% экрана)
            contentAlignment = Alignment.Center // Центрируем текст внутри этой четверти
        ) {
            Text(
                text = "SHESH",
                fontSize = 48.sp,
                fontWeight = FontWeight.Bold
            )
        }

        // --- ОСТАЛЬНЫЕ 3/4 (Подзаголовок) ---
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .weight(3f), // Занимает 3 части из 4 (75% экрана)
            contentAlignment = Alignment.TopCenter // Текст сверху этого блока
        ) {
            Text(
                text = "Make it Shesh",
                fontSize = 24.sp
            )
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
