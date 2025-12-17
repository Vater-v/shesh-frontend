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

    var identityInput by mutableStateOf("")
        private set

    var password by mutableStateOf("")
        private set

    var isIdentitySubmitted by mutableStateOf(false)
        private set

    val isEmailDetected: Boolean
        get() = identityInput.contains("@")

    fun updateIdentity(input: String) {
        identityInput = input
        if (input.isEmpty()) {
            isIdentitySubmitted = false
            password = ""
        }
    }

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
            _uiState.value = LoginUiState.Error("ОШИБКА: ПУСТЫЕ ДАННЫЕ")
            return
        }

        viewModelScope.launch {
            _uiState.value = LoginUiState.Loading
            delay(1500)

            if (password.length >= 6) {
                _uiState.value = LoginUiState.Success
            } else {
                _uiState.value = LoginUiState.Error("ОТКАЗ В ДОСТУПЕ: НЕВЕРНЫЙ КЛЮЧ")
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
