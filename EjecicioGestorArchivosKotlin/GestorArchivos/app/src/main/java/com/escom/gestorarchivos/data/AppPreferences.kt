package com.escom.gestorarchivos.data

import android.content.Context
import android.content.SharedPreferences
import com.escom.gestorarchivos.ui.theme.AppTheme

class AppPreferences(context: Context) {
    private val prefs: SharedPreferences =
        context.getSharedPreferences("app_preferences", Context.MODE_PRIVATE)

    companion object {
        private const val KEY_THEME = "theme"
        private const val KEY_RECENT_FILES = "recent_files"
        private const val KEY_FAVORITES = "favorites"
        private const val MAX_RECENT_FILES = 10
    }

    var selectedTheme: AppTheme
        get() {
            val themeName = prefs.getString(KEY_THEME, AppTheme.GUINDA_IPN.name)
            return try {
                AppTheme.valueOf(themeName ?: AppTheme.GUINDA_IPN.name)
            } catch (e: IllegalArgumentException) {
                AppTheme.GUINDA_IPN
            }
        }
        set(value) {
            prefs.edit().putString(KEY_THEME, value.name).apply()
        }

    fun getRecentFiles(): List<String> {
        val recentFilesString = prefs.getString(KEY_RECENT_FILES, "") ?: ""
        return if (recentFilesString.isEmpty()) {
            emptyList()
        } else {
            recentFilesString.split("|").filter { it.isNotEmpty() }
        }
    }

    fun addRecentFile(filePath: String) {
        val currentFiles = getRecentFiles().toMutableList()
        currentFiles.remove(filePath) // Remover si ya existe
        currentFiles.add(0, filePath) // Agregar al inicio

        // Mantener solo los últimos MAX_RECENT_FILES
        if (currentFiles.size > MAX_RECENT_FILES) {
            currentFiles.removeAt(currentFiles.size - 1)
        }

        val recentFilesString = currentFiles.joinToString("|")
        prefs.edit().putString(KEY_RECENT_FILES, recentFilesString).apply()
    }

    fun getFavorites(): Set<String> {
        return prefs.getStringSet(KEY_FAVORITES, emptySet()) ?: emptySet()
    }

    fun addFavorite(filePath: String) {
        val favorites = getFavorites().toMutableSet()
        favorites.add(filePath)
        prefs.edit().putStringSet(KEY_FAVORITES, favorites).apply()
    }

    fun removeFavorite(filePath: String) {
        val favorites = getFavorites().toMutableSet()
        favorites.remove(filePath)
        prefs.edit().putStringSet(KEY_FAVORITES, favorites).apply()
    }

    fun isFavorite(filePath: String): Boolean {
        return getFavorites().contains(filePath)
    }
}