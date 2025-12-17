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
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

class LoginViewModel : ViewModel() {

    private val _uiState = MutableStateFlow<LoginUiState>(LoginUiState.Idle)
    val uiState = _uiState.asStateFlow()

    var identityInput by mutableStateOf("")
        private set

    var password by mutableStateOf("")
        private set

    // Вспомогательное свойство для смены иконки (Email или Person)
    val isEmailDetected: Boolean get() = identityInput.contains("@")

    fun updateIdentity(input: String) {
        identityInput = input
        clearError()
    }

    fun updatePassword(input: String) {
        password = input
        clearError()
    }

    private fun clearError() {
        if (_uiState.value is LoginUiState.Error) {
            _uiState.update { LoginUiState.Idle }
        }
    }

    fun login() {
        if (identityInput.isBlank() || password.isBlank()) {
            _uiState.update { LoginUiState.Error("Требуются полные учетные данные") }
            return
        }

        viewModelScope.launch {
            _uiState.update { LoginUiState.Loading }
            delay(1500) // Имитация проверки в базе данных
            if (password.length >= 6) {
                _uiState.update { LoginUiState.Success }
            } else {
                _uiState.update { LoginUiState.Error("Доступ запрещен: Неверные данные") }
            }
        }
    }

    fun resetState() {
        _uiState.update { LoginUiState.Idle }
        identityInput = ""
        password = ""
    }
}

sealed interface LoginUiState {
    data object Idle : LoginUiState
    data object Loading : LoginUiState
    data object Success : LoginUiState
    data class Error(val message: String) : LoginUiState
}
