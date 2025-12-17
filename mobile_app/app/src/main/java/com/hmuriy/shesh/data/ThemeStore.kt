//./data/ThemeStore.kt
package com.hmuriy.shesh.data

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

// Создаем расширение для доступа к DataStore (синглтон)
val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "settings")

class ThemeStore(private val context: Context) {

    companion object {
        private val IS_DARK_THEME_KEY = booleanPreferencesKey("is_dark_theme")
    }

    // Читаем настройку. Если пусто -> false (Светлая тема)
    val isDarkTheme: Flow<Boolean> = context.dataStore.data
        .map { preferences ->
            preferences[IS_DARK_THEME_KEY] ?: false
        }

    // Сохраняем настройку
    suspend fun saveTheme(isDark: Boolean) {
        context.dataStore.edit { preferences ->
            preferences[IS_DARK_THEME_KEY] = isDark
        }
    }
}
