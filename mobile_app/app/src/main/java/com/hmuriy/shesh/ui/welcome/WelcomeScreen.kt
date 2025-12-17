//./ui/welkome/WelcomeScreen.kt
package com.hmuriy.shesh.ui.welcome

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.DarkMode
import androidx.compose.material.icons.rounded.LightMode
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.hmuriy.shesh.ui.components.SheshButton

@Composable
fun WelcomeScreen(
    onLoginClick: () -> Unit,
    onRegisterClick: () -> Unit,
    onThemeToggle: () -> Unit,
    isDarkTheme: Boolean
) {
    Box(modifier = Modifier.fillMaxSize()) {
        // 1. Dynamic Background Layer
        AuroraBackground(isDarkTheme)

        // 2. Theme Toggle
        IconButton(
            onClick = onThemeToggle,
            modifier = Modifier
                .align(Alignment.TopEnd)
                .statusBarsPadding()
                .padding(16.dp)
        ) {
            Icon(
                imageVector = if (isDarkTheme) Icons.Rounded.LightMode else Icons.Rounded.DarkMode,
                contentDescription = "Theme",
                tint = MaterialTheme.colorScheme.onBackground
            )
        }

        // 3. Main Content
        Column(
            modifier = Modifier
                .fillMaxSize()
                .systemBarsPadding()
                .padding(horizontal = 24.dp, vertical = 32.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.weight(1f))

            // Hero Typography
            Text(
                text = "SHESH",
                style = MaterialTheme.typography.displayLarge.copy(
                    fontWeight = FontWeight.Black,
                    letterSpacing = 4.sp
                ),
                color = MaterialTheme.colorScheme.onBackground
            )

            Spacer(modifier = Modifier.height(16.dp))

            Text(
                text = "Total control. Zero latency.\nThe architecture of tomorrow.",
                style = MaterialTheme.typography.bodyLarge,
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                lineHeight = 24.sp
            )

            Spacer(modifier = Modifier.weight(1f))

            SheshButton(
                text = "Log In",
                onClick = onLoginClick
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Secondary Action
            OutlinedButton(
                onClick = onRegisterClick,
                modifier = Modifier.fillMaxWidth().height(56.dp),
                shape = MaterialTheme.shapes.medium,
                border = null // Minimalist look
            ) {
                Text(
                    "Create Account",
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                    color = MaterialTheme.colorScheme.onSurface
                )
            }
            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

@Composable
fun AuroraBackground(isDarkTheme: Boolean) {
    val infiniteTransition = rememberInfiniteTransition(label = "bg_anim")

    // Animate scale of a "blob"
    val scale by infiniteTransition.animateFloat(
        initialValue = 1f, targetValue = 1.2f,
        animationSpec = infiniteRepeatable(
            tween(6000, easing = LinearEasing), RepeatMode.Reverse
        ),
        label = "scale"
    )

    val primary = MaterialTheme.colorScheme.primary
    val secondary = MaterialTheme.colorScheme.secondary

    Canvas(modifier = Modifier.fillMaxSize()) {
        val center = center
        // Primary blob (Top Left)
        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(primary.copy(alpha = 0.15f), Color.Transparent),
                center = Offset(center.x * 0.5f, center.y * 0.6f),
                radius = size.minDimension * 0.8f * scale
            )
        )
        // Secondary blob (Bottom Right)
        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(secondary.copy(alpha = 0.1f), Color.Transparent),
                center = Offset(center.x * 1.5f, center.y * 1.4f),
                radius = size.minDimension * 0.7f * scale
            )
        )
    }
}
