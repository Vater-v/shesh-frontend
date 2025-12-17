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

    // 0 = Личный, 1 = Анонимный
    var selectedTabIndex by mutableIntStateOf(0)
        private set

    // Поля ввода
    var email by mutableStateOf("")
    var username by mutableStateOf("")
    var password by mutableStateOf("")

    fun switchTab(index: Int) {
        selectedTabIndex = index
        _uiState.value = RegisterUiState.Idle
        // Очищаем email при переключении на анонимный режим
        if (index == 1) email = ""
    }

    fun register() {
        // Валидация общих полей
        if (username.isBlank() || password.isBlank()) {
            _uiState.value = RegisterUiState.Error("Пожалуйста, заполните все обязательные поля")
            return
        }

        // Валидация Email только для стандартного режима
        if (selectedTabIndex == 0 && (email.isBlank() || !email.contains("@"))) {
            _uiState.value = RegisterUiState.Error("Некорректный формат Email")
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
