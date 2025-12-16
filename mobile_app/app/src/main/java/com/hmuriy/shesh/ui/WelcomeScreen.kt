package com.hmuriy.shesh.ui

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shadow
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.hmuriy.shesh.R
import com.hmuriy.shesh.ui.theme.SheshCyan
import com.hmuriy.shesh.ui.theme.SheshMagenta
import com.hmuriy.shesh.ui.theme.SheshTheme

@Composable
fun WelcomeScreen() {
    Box(modifier = Modifier.fillMaxSize()) {
        
        // Контент поверх фона (Лого и Слоган)
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(top = 100.dp), // Отступ сверху, чтобы попасть в "светящуюся" область
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Логотип SHESH
            Text(
                text = "SHESH",
                color = Color.White,
                fontSize = 64.sp,
                fontWeight = FontWeight.ExtraBold, // Максимально жирный
                style = TextStyle(
                    shadow = Shadow(
                        color = SheshCyan, // Неоновое свечение (Cyan)
                        offset = Offset(0f, 0f),
                        blurRadius = 30f // Радиус размытия для эффекта свечения
                    )
                )
            )

            // Слоган Make it Shesh
            Text(
                text = "Make it Shesh",
                color = Color.White,
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                fontStyle = FontStyle.Italic, // Курсив
                style = TextStyle(
                    shadow = Shadow(
                        color = SheshMagenta, // Подсветка Magenta
                        offset = Offset(0f, 0f),
                        blurRadius = 15f
                    )
                ),
                modifier = Modifier.padding(top = 8.dp)
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
