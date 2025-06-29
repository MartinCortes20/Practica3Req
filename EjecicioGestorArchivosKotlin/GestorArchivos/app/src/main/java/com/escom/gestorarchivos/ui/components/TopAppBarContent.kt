package com.escom.gestorarchivos.ui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.escom.gestorarchivos.ui.theme.AppTheme
import java.io.File

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TopAppBarContent(
    currentDirectory: File?,
    canNavigateUp: Boolean,
    showHiddenFiles: Boolean,
    currentTheme: AppTheme,
    onNavigateUp: () -> Unit,
    onNavigateToRoot: () -> Unit,
    onToggleSearch: () -> Unit,
    onToggleHiddenFiles: () -> Unit,
    onThemeChange: (AppTheme) -> Unit
) {
    var showMenu by remember { mutableStateOf(false) }
    var showThemeMenu by remember { mutableStateOf(false) }

    TopAppBar(
        title = {
            Text(
                text = currentDirectory?.name ?: "Gestor de Archivos",
                fontWeight = FontWeight.Medium,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        },
        navigationIcon = {
            if (canNavigateUp) {
                IconButton(onClick = onNavigateUp) {
                    Icon(
                        imageVector = Icons.Default.ArrowBack,
                        contentDescription = "Volver"
                    )
                }
            }
        },
        actions = {
            // Botón de búsqueda
            IconButton(onClick = onToggleSearch) {
                Icon(
                    imageVector = Icons.Default.Search,
                    contentDescription = "Buscar"
                )
            }

            // Botón home
            IconButton(onClick = onNavigateToRoot) {
                Icon(
                    imageVector = Icons.Default.Home,
                    contentDescription = "Ir al inicio"
                )
            }

            // Menú de opciones
            Box {
                IconButton(onClick = { showMenu = true }) {
                    Icon(
                        imageVector = Icons.Default.MoreVert,
                        contentDescription = "Más opciones"
                    )
                }

                DropdownMenu(
                    expanded = showMenu,
                    onDismissRequest = { showMenu = false }
                ) {
                    DropdownMenuItem(
                        text = {
                            Text(if (showHiddenFiles) "Ocultar archivos ocultos" else "Mostrar archivos ocultos")
                        },
                        onClick = {
                            showMenu = false
                            onToggleHiddenFiles()
                        },
                        leadingIcon = {
                            Icon(
                                imageVector = if (showHiddenFiles) Icons.Default.VisibilityOff else Icons.Default.Visibility,
                                contentDescription = null
                            )
                        }
                    )

                    DropdownMenuItem(
                        text = { Text("Cambiar tema") },
                        onClick = {
                            showMenu = false
                            showThemeMenu = true
                        },
                        leadingIcon = {
                            Icon(
                                imageVector = Icons.Default.Settings,
                                contentDescription = null
                            )
                        }
                    )
                }

                // Submenú de temas
                DropdownMenu(
                    expanded = showThemeMenu,
                    onDismissRequest = { showThemeMenu = false }
                ) {
                    DropdownMenuItem(
                        text = {
                            Text(
                                "Tema Guinda (IPN)",
                                fontWeight = if (currentTheme == AppTheme.GUINDA_IPN) FontWeight.Bold else FontWeight.Normal
                            )
                        },
                        onClick = {
                            showThemeMenu = false
                            onThemeChange(AppTheme.GUINDA_IPN)
                        }
                    )

                    DropdownMenuItem(
                        text = {
                            Text(
                                "Tema Azul (ESCOM)",
                                fontWeight = if (currentTheme == AppTheme.AZUL_ESCOM) FontWeight.Bold else FontWeight.Normal
                            )
                        },
                        onClick = {
                            showThemeMenu = false
                            onThemeChange(AppTheme.AZUL_ESCOM)
                        }
                    )
                }
            }
        },
        colors = TopAppBarDefaults.topAppBarColors()
    )
}