package com.hmuriy.shesh.ui.welcome

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.GoogleAuthProvider
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * ViewModel для экрана приветствия (WelcomeScreen).
 * Отвечает за логику входа через внешние провайдеры (Google) и управление состоянием UI.
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
            // 1. Устанавливаем состояние загрузки (UI должен показать Spinner/Loader)
            _uiState.value = WelcomeUiState.Loading

            try {
                // Создаем учетные данные для Firebase на основе токена от Google
                val credential = GoogleAuthProvider.getCredential(googleIdToken, null)
                val auth = FirebaseAuth.getInstance()

                // 2. Выполняем вход в Firebase
                auth.signInWithCredential(credential)
                    .addOnSuccessListener { authResult ->
                        // Успешный вход -> обновляем состояние
                        // Firebase сам сохранит сессию, можно переходить дальше
                        _uiState.value = WelcomeUiState.Success
                    }
                    .addOnFailureListener { e ->
                        // Ошибка со стороны Firebase (например, нет сети или аккаунт заблокирован)
                        _uiState.value = WelcomeUiState.Error(e.message ?: "Ошибка входа через Firebase")
                    }

            } catch (e: Exception) {
                // 3. Обработка прочих ошибок
                _uiState.value = WelcomeUiState.Error(e.message ?: "Непредвиденная ошибка входа")
            }
        }
    }

    /**
     * Сброс состояния (например, если пользователь нажал "ОК" на диалоге ошибки).
     */
    fun resetState() {
        _uiState.value = WelcomeUiState.Idle
    }
}

/**
 * Описание возможных состояний экрана Welcome.
 */
sealed interface WelcomeUiState {
    // Режим ожидания (пользователь ничего не нажал)
    data object Idle : WelcomeUiState

    // Идет процесс входа (показать ProgressBar)
    data object Loading : WelcomeUiState

    // Вход выполнен успешно (команда для навигации)
    data object Success : WelcomeUiState

    // Произошла ошибка (показать SnackBar или Dialog)
    data class Error(val message: String) : WelcomeUiState
}
