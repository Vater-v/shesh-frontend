//./MainViewModel.kt
package com.hmuriy.shesh

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.hmuriy.shesh.data.ThemeStore
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class MainViewModel(application: Application) : AndroidViewModel(application) {

    private val themeStore = ThemeStore(application)

    // Default to Dark Theme (Cyberpunk) if not set
    val isDarkTheme: StateFlow<Boolean> = themeStore.isDarkTheme
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = true
        )

    fun toggleTheme() {
        viewModelScope.launch {
            themeStore.saveTheme(!isDarkTheme.value)
        }
    }
}
