package com.escom.gestorarchivos.viewmodel

import android.app.Application
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.escom.gestorarchivos.data.AppPreferences
import com.escom.gestorarchivos.data.FileItem
import com.escom.gestorarchivos.ui.theme.AppTheme
import com.escom.gestorarchivos.utils.FileManager
import com.escom.gestorarchivos.utils.PermissionManager
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.io.File

class FileManagerViewModel(application: Application) : AndroidViewModel(application) {

    private val fileManager = FileManager(application)
    private val permissionManager = PermissionManager(application)
    private val appPreferences = AppPreferences(application)

    // Estados de UI
    private val _currentDirectory = MutableStateFlow<File?>(null)
    val currentDirectory: StateFlow<File?> = _currentDirectory.asStateFlow()

    private val _fileItems = MutableStateFlow<List<FileItem>>(emptyList())
    val fileItems: StateFlow<List<FileItem>> = _fileItems.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _hasStoragePermission = MutableStateFlow(false)
    val hasStoragePermission: StateFlow<Boolean> = _hasStoragePermission.asStateFlow()

    private val _currentTheme = MutableStateFlow(appPreferences.selectedTheme)
    val currentTheme: StateFlow<AppTheme> = _currentTheme.asStateFlow()

    private val _navigationStack = MutableStateFlow<List<File>>(emptyList())
    val navigationStack: StateFlow<List<File>> = _navigationStack.asStateFlow()

    private val _recentFiles = MutableStateFlow<List<String>>(emptyList())
    val recentFiles: StateFlow<List<String>> = _recentFiles.asStateFlow()

    private val _favorites = MutableStateFlow<Set<String>>(emptySet())
    val favorites: StateFlow<Set<String>> = _favorites.asStateFlow()

    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    private val _searchResults = MutableStateFlow<List<FileItem>>(emptyList())
    val searchResults: StateFlow<List<FileItem>> = _searchResults.asStateFlow()

    private val _showHiddenFiles = MutableStateFlow(false)
    val showHiddenFiles: StateFlow<Boolean> = _showHiddenFiles.asStateFlow()

    init {
        checkStoragePermission()
        loadRecentFiles()
        loadFavorites()

        // Intentar cargar el directorio inicial
        if (permissionManager.hasStoragePermission()) {
            val initialDir = fileManager.getExternalStorageDirectory()
                ?: fileManager.getInternalStorageDirectory()
            navigateToDirectory(initialDir)
        }
    }

    fun checkStoragePermission() {
        _hasStoragePermission.value = permissionManager.hasStoragePermission()
    }

    fun navigateToDirectory(directory: File) {
        if (!directory.exists() || !directory.isDirectory) return

        viewModelScope.launch {
            _isLoading.value = true

            try {
                _currentDirectory.value = directory
                val items = fileManager.getDirectoryContents(directory, _showHiddenFiles.value)
                _fileItems.value = items

                // Actualizar stack de navegación
                val currentStack = _navigationStack.value.toMutableList()
                currentStack.add(directory)
                _navigationStack.value = currentStack

            } catch (e: Exception) {
                // Manejar error
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun navigateUp() {
        _currentDirectory.value?.let { current ->
            fileManager.getParentDirectory(current.absolutePath)?.let { parent ->
                navigateToDirectory(parent)

                // Actualizar stack removiendo el último elemento
                val currentStack = _navigationStack.value.toMutableList()
                if (currentStack.isNotEmpty()) {
                    currentStack.removeAt(currentStack.size - 1)
                    _navigationStack.value = currentStack
                }
            }
        }
    }

    fun navigateToRoot() {
        val rootDir = fileManager.getExternalStorageDirectory()
            ?: fileManager.getInternalStorageDirectory()
        navigateToDirectory(rootDir)
        _navigationStack.value = listOf(rootDir)
    }

    fun navigateToFolder(folderName: String) {
        when (folderName.lowercase()) {
            "downloads", "descargas" -> navigateToDirectory(fileManager.getDownloadsDirectory())
            "documents", "documentos" -> navigateToDirectory(fileManager.getDocumentsDirectory())
            "pictures", "imágenes" -> navigateToDirectory(fileManager.getPicturesDirectory())
            "music", "música" -> navigateToDirectory(fileManager.getMusicDirectory())
            else -> {
                // Buscar carpeta por nombre en el directorio actual
                _currentDirectory.value?.let { current ->
                    val targetFolder = File(current, folderName)
                    if (targetFolder.exists() && targetFolder.isDirectory) {
                        navigateToDirectory(targetFolder)
                    }
                }
            }
        }
    }

    fun openFile(fileItem: FileItem) {
        if (fileItem.isDirectory) {
            navigateToDirectory(fileItem.file)
        } else {
            addToRecentFiles(fileItem.path)
        }
    }

    fun openFileWithExternalApp(fileItem: FileItem): Intent? {
        return fileManager.openFileWithExternalApp(fileItem.file)
    }

    fun readTextFile(fileItem: FileItem): String? {
        return fileManager.readTextFile(fileItem.file)
    }

    fun changeTheme(theme: AppTheme) {
        _currentTheme.value = theme
        appPreferences.selectedTheme = theme
    }

    fun toggleShowHiddenFiles() {
        _showHiddenFiles.value = !_showHiddenFiles.value
        _currentDirectory.value?.let { directory ->
            viewModelScope.launch {
                val items = fileManager.getDirectoryContents(directory, _showHiddenFiles.value)
                _fileItems.value = items
            }
        }
    }

    fun searchFiles(query: String) {
        _searchQuery.value = query

        if (query.isBlank()) {
            _searchResults.value = emptyList()
            return
        }

        _currentDirectory.value?.let { directory ->
            viewModelScope.launch {
                _isLoading.value = true
                try {
                    val results = fileManager.searchFiles(directory, query, _showHiddenFiles.value)
                    _searchResults.value = results
                } finally {
                    _isLoading.value = false
                }
            }
        }
    }

    fun clearSearch() {
        _searchQuery.value = ""
        _searchResults.value = emptyList()
    }

    private fun addToRecentFiles(filePath: String) {
        appPreferences.addRecentFile(filePath)
        loadRecentFiles()
    }

    private fun loadRecentFiles() {
        _recentFiles.value = appPreferences.getRecentFiles()
    }

    private fun loadFavorites() {
        _favorites.value = appPreferences.getFavorites()
    }

    fun addToFavorites(filePath: String) {
        appPreferences.addFavorite(filePath)
        loadFavorites()
    }

    fun removeFromFavorites(filePath: String) {
        appPreferences.removeFavorite(filePath)
        loadFavorites()
    }

    fun isFavorite(filePath: String): Boolean {
        return appPreferences.isFavorite(filePath)
    }

    fun getStoragePermissionIntent(): Intent? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION).apply {
                data = Uri.parse("package:${getApplication<Application>().packageName}")
            }
        } else {
            null
        }
    }

    fun getRequiredPermissions(): Array<String> {
        return permissionManager.getRequiredPermissions()
    }
}