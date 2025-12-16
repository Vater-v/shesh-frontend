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
            // 1. Показываем загрузку
            _uiState.value = WelcomeUiState.Loading

            try {
                // --- ШАГ 1: Вход в Firebase ---
                val credential = GoogleAuthProvider.getCredential(googleIdToken, null)
                val auth = FirebaseAuth.getInstance()

                // Используем await() чтобы дождаться результата в корутине (вместо callback-ов)
                val authResult = auth.signInWithCredential(credential).await()
                val firebaseUser = authResult.user

                if (firebaseUser == null) {
                    throw Exception("Не удалось получить пользователя Firebase")
                }

                // --- ШАГ 2: Отправка данных на Ваш Бэкенд ---
                // Здесь мы берем данные пользователя и токен, чтобы зарегистрировать
                // или авторизовать его на вашем сервере.

                // Примечание: Для валидации на бэкенде можно слать googleIdToken
                // или получить свежий токен Firebase: firebaseUser.getIdToken(true).await()

                val backendToken = loginToBackend(
                    idToken = googleIdToken,
                    email = firebaseUser.email,
                    name = firebaseUser.displayName,
                    photoUrl = firebaseUser.photoUrl?.toString()
                )

                // --- ШАГ 3: Сохранение сессии ---
                // TODO: Сохраните backendToken в DataStore или SharedPreferences
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
