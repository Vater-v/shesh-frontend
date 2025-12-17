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

    var email by mutableStateOf("")
        private set
    var password by mutableStateOf("")
        private set

    fun updateEmail(input: String) { email = input }
    fun updatePassword(input: String) { password = input }

    fun login() {
        if (email.isBlank() || password.isBlank()) {
            _uiState.value = LoginUiState.Error("Заполните все поля")
            return
        }

        viewModelScope.launch {
            _uiState.value = LoginUiState.Loading

            // TODO: Замените на реальный API вызов
            delay(1500) // Эмуляция сети

            // Простая проверка (заглушка)
            if (password.length >= 6) {
                _uiState.value = LoginUiState.Success
            } else {
                _uiState.value = LoginUiState.Error("Неверный логин или пароль")
            }
        }
    }

    fun resetState() {
        _uiState.value = LoginUiState.Idle
    }
}

sealed interface LoginUiState {
    data object Idle : LoginUiState
    data object Loading : LoginUiState
    data object Success : LoginUiState
    data class Error(val message: String) : LoginUiState
}
