package com.example.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val DarkColorScheme = darkColorScheme(
    primary = EmeraldPrimary,
    secondary = LeafSecondary,
    tertiary = SunburstYellow,
    background = DarkGrey,
    surface = DarkGrey,
    onPrimary = CleanWhiteCard,
    onSecondary = CleanWhiteCard,
    onBackground = OffWhiteBg,
    onSurface = OffWhiteBg
)

private val LightColorScheme = lightColorScheme(
    primary = EmeraldPrimary,
    secondary = LeafSecondary,
    tertiary = CoralAccent,
    background = OffWhiteBg,
    surface = CleanWhiteCard,
    onPrimary = CleanWhiteCard,
    onSecondary = CleanWhiteCard,
    onBackground = TextDark,
    onSurface = TextDark
)

@Composable
fun MyApplicationTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    // Keep parameter for MainActivity compatibility
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}
