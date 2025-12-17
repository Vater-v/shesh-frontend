//./ui/welcome/WelcomeViewModel.kt
package com.hmuriy.shesh.ui.welcome

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.GoogleAuthProvider
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

/**
 * ViewModel для экрана приветствия (WelcomeScreen).
 * Отвечает за логику входа через внешние провайдеры (Google),
 * синхронизацию с Firebase и отправку данных на собственный бэкенд.
 */
class WelcomeViewModel : ViewModel() {

    // Внутреннее изменяемое состояние
    private val _uiState = MutableStateFlow<WelcomeUiState>(WelcomeUiState.Idle)

    // Публичное неизменяемое состояние, на которое подписывается UI
    val uiState: StateFlow<WelcomeUiState> = _uiState.asStateFlow()

    /**
     * Обработка входа через Google.
     * @param googleIdToken Токен, полученный от Google Credential Manager в UI.
     */
    fun handleGoogleSignIn(googleIdToken: String) {
        viewModelScope.launch {
            _uiState.value = WelcomeUiState.Loading

            try {
                // --- ШАГ 1: Логинимся в Firebase с помощью Google токена (на клиенте) ---
                val credential = GoogleAuthProvider.getCredential(googleIdToken, null)
                val auth = FirebaseAuth.getInstance()

                // Используем await() чтобы дождаться результата в корутине
                val authResult = auth.signInWithCredential(credential).await()
                val firebaseUser = authResult.user ?: throw Exception("User is null")

                // --- ШАГ 2: ПОЛУЧАЕМ ТОКЕН ДЛЯ БЭКЕНДА ---
                // getIdToken(true) заставляет обновить токен и возвращает сырой JWT (Firebase ID Token).
                // Это тот самый токен, который нужно слать на бэкенд для проверки через Admin SDK.
                val tokenResult = firebaseUser.getIdToken(true).await()
                val tokenForBackend = tokenResult.token

                if (tokenForBackend == null) throw Exception("Backend token is null")

                // --- ШАГ 3: Отправляем на сервер именно tokenForBackend ---
                val backendToken = loginToBackend(
                    idToken = tokenForBackend, // <--- Шлем этот токен (Firebase JWT)!
                    email = firebaseUser.email,
                    name = firebaseUser.displayName,
                    photoUrl = firebaseUser.photoUrl?.toString()
                )

                // --- ШАГ 4: Сохранение сессии ---
                // TODO: Сохраните backendToken (сессионный токен вашего бэкенда) в DataStore или SharedPreferences
                // sessionManager.saveAuthToken(backendToken)
                Log.d("WelcomeViewModel", "Backend token received: $backendToken")

                // Успех -> UI перейдет на следующий экран
                _uiState.value = WelcomeUiState.Success

            } catch (e: Exception) {
                // Обработка ошибок (сеть, неверный токен и т.д.)
                Log.e("WelcomeViewModel", "Sign in error", e)
                _uiState.value = WelcomeUiState.Error(e.message ?: "Ошибка авторизации")
            }
        }
    }

    /**
     * Заглушка для вызова API вашего бэкенда.
     * В будущем замените этот код на вызов Retrofit.
     */
    private suspend fun loginToBackend(
        idToken: String,
        email: String?,
        name: String?,
        photoUrl: String?
    ): String {
        // Эмуляция сетевой задержки
        delay(1500)

        // TODO: Реализовать запрос к API:
        // val response = apiService.authWithGoogle(
        //     AuthRequest(token = idToken, email = email, name = name, avatar = photoUrl)
        // )
        // return response.token

        // Пока возвращаем фейковый токен
        Log.d("WelcomeViewModel", "Logging in to backend with token: ${idToken.take(10)}...")
        return "mock_backend_jwt_token_example_12345"
    }

    /**
     * Сброс состояния (например, при выходе или ошибке).
     */
    fun resetState() {
        _uiState.value = WelcomeUiState.Idle
    }
}

/**
 * Описание возможных состояний экрана Welcome.
 */
sealed interface WelcomeUiState {
    data object Idle : WelcomeUiState
    data object Loading : WelcomeUiState
    data object Success : WelcomeUiState
    data class Error(val message: String) : WelcomeUiState
}
