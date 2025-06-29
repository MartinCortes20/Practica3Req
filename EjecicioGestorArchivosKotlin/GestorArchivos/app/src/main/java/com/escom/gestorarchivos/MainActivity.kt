package com.escom.gestorarchivos

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.lifecycle.viewmodel.compose.viewModel
import com.escom.gestorarchivos.ui.screens.FileManagerScreen
import com.escom.gestorarchivos.ui.theme.GestorArchivosTheme
import com.escom.gestorarchivos.viewmodel.FileManagerViewModel

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            val viewModel: FileManagerViewModel = viewModel()
            val currentTheme by viewModel.currentTheme.collectAsState()
            val darkTheme = isSystemInDarkTheme()

            GestorArchivosTheme(
                theme = currentTheme,
                darkTheme = darkTheme
            ) {
                FileManagerScreen(viewModel = viewModel)
            }
        }
    }
}