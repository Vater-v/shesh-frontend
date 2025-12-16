package com.hmuriy.shesh.ui

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
import androidx.compose.ui.graphics.Color

@Composable
fun WelcomeScreen() {
    Column (modifier = Modifier.fillMaxSize(), Arrangement.SpaceAround){
        Box(
            modifier = Modifier
                .fillMaxWidth()        // Ширина на весь экран
                .fillMaxHeight(0.2f)   // Высота 20% от доступного места (0.2f)
                .background(Color.Gray) // Раскомментируйте, чтобы увидеть границы
        ){Text("SHESH", fontSize = 48.sp, color = Theme.primary)}
        Text("Java", fontSize = 28.sp)
        Text("JavaScript", fontSize = 28.sp)
        Text("Python", fontSize = 28.sp)
    }

//    {
//        Box(
//            modifier = Modifier
//                .fillMaxWidth()
//                .weight(1f),
//
//            contentAlignment = Alignment.TopCenter
//        ) {
//            Text(
//                text = "SHESH",
//                fontSize = 48.sp,
//                fontWeight = FontWeight.Bold,
//                // Устанавливаем фирменный "Электрический циан"
//                color = CyberCyan,
//
//            )
//        }
//
//        Box(
//            modifier = Modifier
//                .fillMaxWidth()
//                .weight(2f),
//            contentAlignment = Alignment.BottomCenter
//        ) {
//            Text(
//                text = "Make it Shesh",
//                fontSize = 24.sp,
//                // Устанавливаем основной светлый цвет текста
//                color = TextWhite
//            )
//        }
//    }
}

@Preview(showBackground = true)
@Composable
fun WelcomeScreenPreview() {
    SheshTheme {
        WelcomeScreen()
    }
}
