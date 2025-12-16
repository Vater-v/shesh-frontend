package com.hmuriy.shesh.ui.welcome

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.delay
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
     * Обработка нажатия на кнопку "Войти через Google".
     */
    fun handleGoogleSignIn() {
        viewModelScope.launch {
            // 1. Устанавливаем состояние загрузки (UI должен показать Spinner/Loader)
            _uiState.value = WelcomeUiState.Loading

            try {
                // TODO: ИНТЕГРАЦИЯ С GOOGLE AUTH
                // Здесь должен быть реальный вызов вашего репозитория или Google SignIn Client.
                // Например: val user = authRepository.signInWithGoogle(idToken)

                // --- Имитация сетевой задержки (удалить при реализации) ---
                delay(2000)
                // ---------------------------------------------------------

                // 2. Успешный вход
                _uiState.value = WelcomeUiState.Success
            } catch (e: Exception) {
                // 3. Обработка ошибки
                _uiState.value = WelcomeUiState.Error(e.message ?: "Ошибка входа через Google")
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
