package com.hmuriy.myapplication

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.net.HttpURLConnection
import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.Socket
import java.net.URL

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            // Тема по умолчанию, просто черный фон
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black)
            ) {
                NetworkTestScreen()
            }
        }
    }
}

@Composable
fun NetworkTestScreen() {
    // Простейшее состояние: Текст лога и флаг загрузки
    var logText by remember { mutableStateOf("Ready to test.") }
    var isLoading by remember { mutableStateOf(false) }

    // Coroutine Scope для запуска фоновых задач
    val scope = rememberCoroutineScope()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .systemBarsPadding()
            .padding(16.dp)
    ) {
        Text(
            text = "NATIVE NETWORK CHECK",
            color = Color.Green,
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold,
            fontFamily = FontFamily.Monospace
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Окно лога
        Box(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
                .background(Color(0xFF111111))
                .padding(12.dp)
                .verticalScroll(rememberScrollState())
        ) {
            Text(
                text = logText,
                color = Color.White,
                fontFamily = FontFamily.Monospace,
                fontSize = 12.sp
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        Button(
            onClick = {
                // Запускаем тест в корутине
                scope.launch {
                    isLoading = true
                    logText = "Running diagnostics..."
                    // Выполняем тяжелую работу в IO потоке
                    val result = runNetworkDiagnostics()
                    logText = result
                    isLoading = false
                }
            },
            enabled = !isLoading,
            modifier = Modifier.fillMaxWidth().height(56.dp)
        ) {
            Text(if (isLoading) "TESTING..." else "RUN GOOGLE TEST")
        }
    }
}

// --- ВСЯ СЕТЕВАЯ МАГИЯ ЗДЕСЬ ---
// Используем чистую Java/Kotlin Standard Library. Никаких Retrofit/OkHttp.
suspend fun runNetworkDiagnostics(): String = withContext(Dispatchers.IO) {
    val sb = StringBuilder()
    sb.append("=== START DIAGNOSTICS ===\n")

    // 1. RAW SOCKET TEST (8.8.8.8)
    // Проверяем, есть ли физический выход в интернет (роутинг)
    sb.append("\n[1] TCP Connect (8.8.8.8:53)... ")
    try {
        val socket = Socket()
        socket.connect(InetSocketAddress("8.8.8.8", 53), 2500) // 2.5 сек таймаут
        socket.close()
        sb.append("OK ✅\n   -> Internet Routing works.\n")
    } catch (e: Exception) {
        sb.append("FAIL ❌\n   -> Error: ${e.message}\n   -> CHECK WIFI/DATA!\n")
        return@withContext sb.toString() // Смысла продолжать нет
    }

    // 2. DNS RESOLVE TEST
    // Проверяем, работает ли DNS сервер провайдера
    sb.append("\n[2] DNS Resolve (google.com)... ")
    try {
        val address = InetAddress.getByName("google.com")
        sb.append("OK ✅\n   -> IP: ${address.hostAddress}\n")
    } catch (e: Exception) {
        sb.append("FAIL ❌\n   -> Error: ${e.message}\n   -> DNS SERVER IS DEAD.\n")
    }

    // 3. HTTP CONNECTION TEST
    // Проверяем, работает ли веб
    sb.append("\n[3] HTTP Request (www.google.com)... ")
    try {
        val url = URL("https://www.google.com")
        val conn = url.openConnection() as HttpURLConnection
        conn.connectTimeout = 3000
        conn.readTimeout = 3000
        conn.requestMethod = "HEAD" // Экономим трафик, просим только заголовки

        val code = conn.responseCode
        if (code == 200) {
            sb.append("OK (200) ✅\n   -> Full Internet Access confirmed.\n")
        } else {
            sb.append("WARNING ($code) ⚠️\n")
        }
        conn.disconnect()
    } catch (e: Exception) {
        sb.append("FAIL ❌\n   -> Error: ${e.message}\n")
    }

    sb.append("\n=== END DIAGNOSTICS ===")
    return@withContext sb.toString()
}
