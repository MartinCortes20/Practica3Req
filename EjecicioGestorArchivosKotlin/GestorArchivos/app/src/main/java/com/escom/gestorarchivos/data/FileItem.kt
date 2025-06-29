package com.escom.gestorarchivos.data

import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

data class FileItem(
    val file: File,
    val name: String = file.name,
    val path: String = file.absolutePath,
    val isDirectory: Boolean = file.isDirectory,
    val size: Long = if (file.isDirectory) 0 else file.length(),
    val lastModified: Long = file.lastModified(),
    val extension: String = if (file.isDirectory) "" else file.extension.lowercase(),
    val isHidden: Boolean = file.isHidden
) {

    fun getFormattedSize(): String {
        if (isDirectory) return "Carpeta"

        return when {
            size < 1024 -> "$size B"
            size < 1024 * 1024 -> "${size / 1024} KB"
            size < 1024 * 1024 * 1024 -> "${size / (1024 * 1024)} MB"
            else -> "${size / (1024 * 1024 * 1024)} GB"
        }
    }

    fun getFormattedDate(): String {
        val formatter = SimpleDateFormat("dd/MM/yyyy HH:mm", Locale.getDefault())
        return formatter.format(Date(lastModified))
    }

    fun getFileType(): FileType {
        return when {
            isDirectory -> FileType.DIRECTORY
            extension in listOf("txt", "md", "log", "xml", "json") -> FileType.TEXT
            extension in listOf("jpg", "jpeg", "png", "gif", "bmp", "webp") -> FileType.IMAGE
            extension in listOf("mp3", "wav", "ogg", "m4a") -> FileType.AUDIO
            extension in listOf("mp4", "avi", "mkv", "mov") -> FileType.VIDEO
            extension in listOf("pdf") -> FileType.PDF
            extension in listOf("doc", "docx") -> FileType.DOCUMENT
            extension in listOf("zip", "rar", "7z") -> FileType.ARCHIVE
            else -> FileType.OTHER
        }
    }

    fun canOpen(): Boolean {
        return getFileType() in listOf(FileType.TEXT, FileType.IMAGE)
    }
}

enum class FileType {
    DIRECTORY,
    TEXT,
    IMAGE,
    AUDIO,
    VIDEO,
    PDF,
    DOCUMENT,
    ARCHIVE,
    OTHER
}