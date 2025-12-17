//./ui/welcome/WelcomeViewModel.kt
package com.hmuriy.shesh.ui.welcome

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

class WelcomeViewModel : ViewModel() {
    private val _uiState = MutableStateFlow<WelcomeUiState>(WelcomeUiState.Idle)
    val uiState = _uiState.asStateFlow()
}

sealed interface WelcomeUiState {
    data object Idle : WelcomeUiState
}
