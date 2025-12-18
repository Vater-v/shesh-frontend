// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    // Определяем версии плагинов для всего проекта, но не применяем их к самому корню (apply false)
    id("com.android.application") version "8.5.0" apply false
    id("com.android.library") version "8.5.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}
