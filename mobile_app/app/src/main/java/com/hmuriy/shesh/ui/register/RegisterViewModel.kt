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
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class RegisterUiState(
    val isLoading: Boolean = false,
    val isSuccess: Boolean = false,
    val error: String? = null
)

class RegisterViewModel : ViewModel() {

    private val _uiState = MutableStateFlow(RegisterUiState())
    val uiState = _uiState.asStateFlow()

    var selectedTabIndex by mutableIntStateOf(0)
        private set

    // Inputs managed via Compose State for immediate UI responsiveness
    var email by mutableStateOf("")
        private set
    var username by mutableStateOf("")
        private set
    var password by mutableStateOf("")
        private set

    fun switchTab(index: Int) {
        selectedTabIndex = index
        _uiState.update { RegisterUiState() } // Reset state cleanly
        if (index == 1) email = ""
    }

    fun updateEmail(input: String) { email = input; clearError() }
    fun updateUsername(input: String) { username = input; clearError() }
    fun updatePassword(input: String) { password = input; clearError() }

    private fun clearError() {
        if (_uiState.value.error != null) {
            _uiState.update { it.copy(error = null) }
        }
    }

    fun register() {
        // Prevent race condition if already loading
        if (_uiState.value.isLoading) return

        val currentError = validate()
        if (currentError != null) {
            _uiState.update { it.copy(error = currentError) }
            return
        }

        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            delay(2000) // Simulate network
            _uiState.update { it.copy(isLoading = false, isSuccess = true) }
        }
    }

    private fun validate(): String? {
        if (username.isBlank() || password.isBlank()) return "Заполните все обязательные поля"
        if (selectedTabIndex == 0 && (email.isBlank() || !email.contains("@"))) return "Некорректный формат Email"
        if (password.length < 6) return "Пароль должен содержать минимум 6 символов"
        return null
    }
}
