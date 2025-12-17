//./ui/register/RegisterViewModel.kt
package com.hmuriy.shesh.ui.register

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class RegisterViewModel : ViewModel() {

    private val _uiState = MutableStateFlow<RegisterUiState>(RegisterUiState.Idle)
    val uiState = _uiState.asStateFlow()

    // 0 = Secure, 1 = Stealth
    var selectedTabIndex by mutableIntStateOf(0)
        private set

    // Fields
    var email by mutableStateOf("")
    var username by mutableStateOf("")
    var password by mutableStateOf("")

    fun switchTab(index: Int) {
        selectedTabIndex = index
        _uiState.value = RegisterUiState.Idle
        // Очищаем email в Stealth режиме
        if (index == 1) email = ""
    }

    fun register() {
        // Validation
        if (username.isBlank() || password.isBlank()) {
            _uiState.value = RegisterUiState.Error("FIELDS_MISSING")
            return
        }

        // Secure mode requires Email
        if (selectedTabIndex == 0 && (email.isBlank() || !email.contains("@"))) {
            _uiState.value = RegisterUiState.Error("INVALID_EMAIL_PROTOCOL")
            return
        }

        viewModelScope.launch {
            _uiState.value = RegisterUiState.Loading
            delay(2000)
            _uiState.value = RegisterUiState.Success
        }
    }
}

sealed interface RegisterUiState {
    data object Idle : RegisterUiState
    data object Loading : RegisterUiState
    data object Success : RegisterUiState
    data class Error(val message: String) : RegisterUiState
}
