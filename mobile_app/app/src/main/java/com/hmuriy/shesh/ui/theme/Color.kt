package com.hmuriy.shesh.ui.theme

import androidx.compose.ui.graphics.Color

// --- Main Brand Colors ---
// Электрический циан: для кнопок действий, активных тогглов, курсоров
val CyberCyan = Color(0xFF00E5FF)
val CyberCyanDark = Color(0xFF00B2CC) // Для состояний нажатия

// Глубокий фиолетовый: для второстепенных элементов, градиентов
val DeepViolet = Color(0xFF651FFF)
val SoftViolet = Color(0xFF7C4DFF)

// --- Backgrounds & Surfaces (The "Stealth" part) ---
// Не используйте #000000, это дешевит. Используйте глубокие оттенки.
val VoidDark = Color(0xFF0A0E14)      // Основной фон приложения
val SurfaceGunmetal = Color(0xFF1C222E) // Карточки, панели, диалоги
val SurfaceLighter = Color(0xFF2B3240)  // Всплывающие элементы

// --- Status Colors (Terminal vibes) ---
val TerminalGreen = Color(0xFF00E676) // Успех, "Online", "Running"
val WarningAmber = Color(0xFFFFEA00)  // Предупреждение, капча
val CriticalRed = Color(0xFFFF1744)   // Ошибка, бан, "Offline"

// --- Content Colors ---
val TextWhite = Color(0xFFEEEEEE)     // Основной текст (не чисто белый)
val TextGray = Color(0xFF9E9E9E)      // Вторичный текст, логи, метаданные
