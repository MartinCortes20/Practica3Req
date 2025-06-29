package com.escom.gestorarchivos.ui.theme

import android.app.Activity
import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

// Enum para los temas disponibles
enum class AppTheme {
    GUINDA_IPN,
    AZUL_ESCOM
}

// Esquemas de color para tema Guinda IPN
private val GuindaLightColorScheme = lightColorScheme(
    primary = GuindaPrimary,
    onPrimary = GuindaBackgroundLight,
    primaryContainer = GuindaPrimaryVariant,
    onPrimaryContainer = GuindaBackgroundLight,
    secondary = GuindaSecondary,
    onSecondary = GuindaBackgroundDark,
    background = GuindaBackgroundLight,
    onBackground = GuindaBackgroundDark,
    surface = GuindaSurfaceLight,
    onSurface = GuindaBackgroundDark,
    error = ErrorColor
)

private val GuindaDarkColorScheme = darkColorScheme(
    primary = GuindaPrimary,
    onPrimary = GuindaBackgroundLight,
    primaryContainer = GuindaPrimaryVariant,
    onPrimaryContainer = GuindaBackgroundLight,
    secondary = GuindaSecondary,
    onSecondary = GuindaBackgroundDark,
    background = GuindaBackgroundDark,
    onBackground = GuindaBackgroundLight,
    surface = GuindaSurfaceDark,
    onSurface = GuindaBackgroundLight,
    error = ErrorColor
)

// Esquemas de color para tema Azul ESCOM
private val AzulLightColorScheme = lightColorScheme(
    primary = AzulPrimary,
    onPrimary = AzulBackgroundLight,
    primaryContainer = AzulPrimaryVariant,
    onPrimaryContainer = AzulBackgroundLight,
    secondary = AzulSecondary,
    onSecondary = AzulBackgroundDark,
    background = AzulBackgroundLight,
    onBackground = AzulBackgroundDark,
    surface = AzulSurfaceLight,
    onSurface = AzulBackgroundDark,
    error = ErrorColor
)

private val AzulDarkColorScheme = darkColorScheme(
    primary = AzulPrimary,
    onPrimary = AzulBackgroundLight,
    primaryContainer = AzulPrimaryVariant,
    onPrimaryContainer = AzulBackgroundLight,
    secondary = AzulSecondary,
    onSecondary = AzulBackgroundDark,
    background = AzulBackgroundDark,
    onBackground = AzulBackgroundLight,
    surface = AzulSurfaceDark,
    onSurface = AzulBackgroundLight,
    error = ErrorColor
)

@Composable
fun GestorArchivosTheme(
    theme: AppTheme = AppTheme.GUINDA_IPN,
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }

        theme == AppTheme.GUINDA_IPN -> {
            if (darkTheme) GuindaDarkColorScheme else GuindaLightColorScheme
        }

        theme == AppTheme.AZUL_ESCOM -> {
            if (darkTheme) AzulDarkColorScheme else AzulLightColorScheme
        }

        else -> {
            if (darkTheme) GuindaDarkColorScheme else GuindaLightColorScheme
        }
    }

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.primary.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = !darkTheme
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}