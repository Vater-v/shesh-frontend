//./ui/welcome/WelcomeScreen.kt
package com.hmuriy.shesh.ui.welcome

import android.content.Context
import android.util.Log
import androidx.compose.animation.core.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.LightMode
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.TileMode
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.exceptions.GetCredentialException
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.hmuriy.shesh.R
import com.hmuriy.shesh.ui.theme.*
import kotlinx.coroutines.launch

/**
 * Функция для создания анимированной кисти (эффект перелива).
 */
@Composable
fun rememberAnimatedBrush(): Brush {
    val density = LocalDensity.current

    val (distancePx, gradientWidthPx) = with(density) {
        Pair(3000.dp.toPx(), 500.dp.toPx())
    }

    val shimmerColors = listOf(
        CyberCyan,
        DeepViolet,
        Color(0xFFBC13FE),
        CyberCyan
    )

    val transition = rememberInfiniteTransition(label = "shimmer_transition")

    val translateAnimation by transition.animateFloat(
        initialValue = 0f,
        targetValue = distancePx,
        animationSpec = infiniteRepeatable(
            animation = tween(
                durationMillis = 12000,
                easing = LinearEasing
            ),
            repeatMode = RepeatMode.Restart
        ),
        label = "shimmer_offset"
    )

    return Brush.linearGradient(
        colors = shimmerColors,
        start = Offset(translateAnimation, translateAnimation),
        end = Offset(translateAnimation + gradientWidthPx, translateAnimation + gradientWidthPx),
        tileMode = TileMode.Mirror
    )
}

@Composable
fun WelcomeScreen(
    onGoogleSignInSuccess: (String) -> Unit = {},
    onLoginSignUpClick: () -> Unit = {},
    onSignInClick: () -> Unit = {},
    // Новые параметры для переключения темы
    onThemeToggle: () -> Unit = {},
    isDarkTheme: Boolean = false
) {
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()

    // Инициализация Credential Manager
    val credentialManager = remember { CredentialManager.create(context) }

    // Получаем Web Client ID из ресурсов (значение: 325529913880-g4dqacc0iv8k6i9jn9u9l9284gudotsr.apps.googleusercontent.com)
    val webClientId = stringResource(id = R.string.web_client_id)

    Surface(
        modifier = Modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.background
    ) {
        // Оборачиваем верстку в Box для наложения элементов (иконка темы поверх контента)
        Box(modifier = Modifier.fillMaxSize()) {

            // --- КНОПКА ПЕРЕКЛЮЧЕНИЯ ТЕМЫ (Правый верхний угол) ---
            IconButton(
                onClick = onThemeToggle,
                modifier = Modifier
                    .align(Alignment.TopEnd) // Прижимаем к углу
                    .statusBarsPadding()     // Учитываем вырез камеры (Edge-to-Edge)
                    .padding(16.dp)
            ) {
                // Меняем иконку: если темно -> Солнце (чтобы включить свет), если светло -> Луна
                Icon(
                    imageVector = if (isDarkTheme) Icons.Default.LightMode else Icons.Default.DarkMode,
                    contentDescription = "Switch Theme",
                    tint = MaterialTheme.colorScheme.onBackground
                )
            }

            // --- ОСНОВНОЙ КОНТЕНТ ---
            Column(
                modifier = Modifier
                    .fillMaxSize()
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
                    val animatedBrush = rememberAnimatedBrush()

                    Text(
                        text = "SHESH",
                        style = MaterialTheme.typography.displayLarge.copy(
                            fontWeight = FontWeight.Black,
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
                        onClick = {
                            coroutineScope.launch {
                                signInWithGoogle(
                                    context = context,
                                    credentialManager = credentialManager,
                                    webClientId = webClientId,
                                    onSuccess = onGoogleSignInSuccess
                                )
                            }
                        },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(56.dp),
                        shape = MaterialTheme.shapes.medium
                    ) {
                        Icon(
                            painter = painterResource(id = R.drawable.ic_google_logo),
                            contentDescription = "Google Logo",
                            modifier = Modifier.size(24.dp),
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
                        Icon(
                            imageVector = Icons.Default.Email,
                            contentDescription = "Email Icon",
                            modifier = Modifier.size(24.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
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
}

/**
 * Логика входа через Google с использованием Credential Manager.
 */
private suspend fun signInWithGoogle(
    context: Context,
    credentialManager: CredentialManager,
    webClientId: String,
    onSuccess: (String) -> Unit
) {
    try {
        // 1. Формируем опцию для Google ID
        val googleIdOption = GetGoogleIdOption.Builder()
            .setFilterByAuthorizedAccounts(false) // false = показывать все доступные аккаунты
            .setServerClientId(webClientId)       // ID клиента из Google Cloud Console (Firebase)
            .setAutoSelectEnabled(true)           // Авто-выбор, если доступен один аккаунт
            .build()

        // 2. Создаем запрос
        val request = GetCredentialRequest.Builder()
            .addCredentialOption(googleIdOption)
            .build()

        // 3. Показываем системное окно выбора аккаунта
        val result = credentialManager.getCredential(
            request = request,
            context = context
        )

        // 4. Обрабатываем результат
        val credential = result.credential

        // Проверяем тип креда (библиотека googleid предоставляет класс-обертку)
        if (credential is GoogleIdTokenCredential) {
            // Успех!
            val googleIdToken = credential.idToken
            onSuccess(googleIdToken)
        } else if (credential.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL) {
            // Альтернативная проверка (на случай изменения версий библиотек)
            val googleIdTokenCredential = GoogleIdTokenCredential.createFrom(credential.data)
            onSuccess(googleIdTokenCredential.idToken)
        } else {
            Log.e("WelcomeScreen", "Unexpected credential type: ${credential.type}")
        }

    } catch (e: GetCredentialException) {
        // Пользователь отменил вход или произошла ошибка
        Log.e("WelcomeScreen", "Google Sign-In failed or cancelled: ${e.message}")
    } catch (e: Exception) {
        Log.e("WelcomeScreen", "Unexpected error during Sign-In", e)
    }
}

@Preview(showBackground = true)
@Composable
fun WelcomeScreenPreview() {
    SheshTheme {
        WelcomeScreen()
    }
}
