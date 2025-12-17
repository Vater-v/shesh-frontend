//./ui/login/LoginViewModel.kt
package com.hmuriy.shesh.ui.login

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class LoginViewModel : ViewModel() {

    private val _uiState = MutableStateFlow<LoginUiState>(LoginUiState.Idle)
    val uiState = _uiState.asStateFlow()

    // Единое поле ввода идентификатора
    var identityInput by mutableStateOf("")
        private set

    // Пароль
    var password by mutableStateOf("")
        private set

    // Состояние "Подтвержден ли Identity"
    var isIdentitySubmitted by mutableStateOf(false)
        private set

    // Вычисляемое свойство для UI: Email или Username?
    val isEmailDetected: Boolean
        get() = identityInput.contains("@")

    fun updateIdentity(input: String) {
        identityInput = input
        // Если пользователь стер поле, скрываем пароль обратно
        if (input.isEmpty()) {
            isIdentitySubmitted = false
            password = ""
        }
    }

    // Вызывается по нажатию Next/Enter
    fun submitIdentity() {
        if (identityInput.isNotBlank()) {
            isIdentitySubmitted = true
        }
    }

    fun updatePassword(input: String) {
        password = input
    }

    fun login() {
        if (identityInput.isBlank() || password.isBlank()) {
            _uiState.value = LoginUiState.Error("IDENTITY_VERIFICATION_FAILED")
            return
        }

        viewModelScope.launch {
            _uiState.value = LoginUiState.Loading
            delay(1500) // Имитация проверки

            // Заглушка
            if (password.length >= 6) {
                _uiState.value = LoginUiState.Success
            } else {
                _uiState.value = LoginUiState.Error("ACCESS DENIED: INVALID KEY")
            }
        }
    }

    fun resetState() {
        _uiState.value = LoginUiState.Idle
        identityInput = ""
        password = ""
        isIdentitySubmitted = false
    }
}

sealed interface LoginUiState {
    data object Idle : LoginUiState
    data object Loading : LoginUiState
    data object Success : LoginUiState
    data class Error(val message: String) : LoginUiState
}
