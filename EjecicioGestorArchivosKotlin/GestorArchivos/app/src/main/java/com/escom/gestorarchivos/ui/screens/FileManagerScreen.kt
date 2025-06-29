package com.escom.gestorarchivos.ui.screens

import android.content.Intent
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.escom.gestorarchivos.ui.components.BreadcrumbNavigation
import com.escom.gestorarchivos.ui.components.FileItemCard
import com.escom.gestorarchivos.ui.components.PermissionRequestScreen
import com.escom.gestorarchivos.ui.components.SearchBar
import com.escom.gestorarchivos.ui.components.TopAppBarContent
import com.escom.gestorarchivos.viewmodel.FileManagerViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FileManagerScreen(
    viewModel: FileManagerViewModel = viewModel()
) {
    val context = LocalContext.current

    // Estados del ViewModel
    val hasStoragePermission by viewModel.hasStoragePermission.collectAsState()
    val currentDirectory by viewModel.currentDirectory.collectAsState()
    val fileItems by viewModel.fileItems.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val currentTheme by viewModel.currentTheme.collectAsState()
    val navigationStack by viewModel.navigationStack.collectAsState()
    val searchQuery by viewModel.searchQuery.collectAsState()
    val searchResults by viewModel.searchResults.collectAsState()
    val showHiddenFiles by viewModel.showHiddenFiles.collectAsState()
    val favorites by viewModel.favorites.collectAsState()

    // Estados locales
    var showSearch by remember { mutableStateOf(false) }

    // Launcher para solicitar permisos
    val permissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        viewModel.checkStoragePermission()
    }

    // Launcher para configuración de permisos (Android 11+)
    val settingsLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.StartActivityForResult()
    ) {
        viewModel.checkStoragePermission()
    }

    // Verificar permisos al iniciar
    LaunchedEffect(Unit) {
        viewModel.checkStoragePermission()
    }

    if (!hasStoragePermission) {
        PermissionRequestScreen(
            onRequestPermission = {
                val settingsIntent = viewModel.getStoragePermissionIntent()
                if (settingsIntent != null) {
                    settingsLauncher.launch(settingsIntent)
                } else {
                    permissionLauncher.launch(viewModel.getRequiredPermissions())
                }
            }
        )
        return
    }

    Scaffold(
        topBar = {
            TopAppBarContent(
                currentDirectory = currentDirectory,
                canNavigateUp = navigationStack.size > 1,
                showHiddenFiles = showHiddenFiles,
                currentTheme = currentTheme,
                onNavigateUp = { viewModel.navigateUp() },
                onNavigateToRoot = { viewModel.navigateToRoot() },
                onToggleSearch = { showSearch = !showSearch },
                onToggleHiddenFiles = { viewModel.toggleShowHiddenFiles() },
                onThemeChange = { theme -> viewModel.changeTheme(theme) }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            // Barra de búsqueda
            if (showSearch) {
                SearchBar(
                    query = searchQuery,
                    onQueryChange = { query -> viewModel.searchFiles(query) },
                    onClearSearch = {
                        viewModel.clearSearch()
                        showSearch = false
                    }
                )
            }

            // Navegación breadcrumb
            if (!showSearch && navigationStack.isNotEmpty()) {
                BreadcrumbNavigation(
                    navigationStack = navigationStack,
                    onNavigateToPath = { directory -> viewModel.navigateToDirectory(directory) }
                )
            }

            // Contenido principal
            when {
                isLoading -> {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator()
                    }
                }

                showSearch && searchQuery.isNotEmpty() -> {
                    LazyColumn(
                        modifier = Modifier.fillMaxSize()
                    ) {
                        items(searchResults) { fileItem ->
                            FileItemCard(
                                fileItem = fileItem,
                                isFavorite = viewModel.isFavorite(fileItem.path),
                                onItemClick = {
                                    viewModel.openFile(fileItem)
                                    if (fileItem.isDirectory) {
                                        showSearch = false
                                        viewModel.clearSearch()
                                    }
                                },
                                onFavoriteClick = {
                                    if (viewModel.isFavorite(fileItem.path)) {
                                        viewModel.removeFromFavorites(fileItem.path)
                                    } else {
                                        viewModel.addToFavorites(fileItem.path)
                                    }
                                },
                                onOpenWithClick = {
                                    viewModel.openFileWithExternalApp(fileItem)?.let { intent ->
                                        context.startActivity(Intent.createChooser(intent, "Abrir con..."))
                                    }
                                },
                                modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp)
                            )
                        }
                    }
                }

                else -> {
                    LazyColumn(
                        modifier = Modifier.fillMaxSize()
                    ) {
                        items(fileItems) { fileItem ->
                            FileItemCard(
                                fileItem = fileItem,
                                isFavorite = viewModel.isFavorite(fileItem.path),
                                onItemClick = { viewModel.openFile(fileItem) },
                                onFavoriteClick = {
                                    if (viewModel.isFavorite(fileItem.path)) {
                                        viewModel.removeFromFavorites(fileItem.path)
                                    } else {
                                        viewModel.addToFavorites(fileItem.path)
                                    }
                                },
                                onOpenWithClick = {
                                    viewModel.openFileWithExternalApp(fileItem)?.let { intent ->
                                        context.startActivity(Intent.createChooser(intent, "Abrir con..."))
                                    }
                                },
                                modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp)
                            )
                        }
                    }
                }
            }
        }
    }
}