package com.escom.gestorarchivos.utils

import android.content.Context
import android.content.Intent
import android.os.Environment
import androidx.core.content.FileProvider
import com.escom.gestorarchivos.data.FileItem
import java.io.File

class FileManager(private val context: Context) {

    fun getInternalStorageDirectory(): File {
        return context.filesDir
    }

    fun getExternalStorageDirectory(): File? {
        return if (Environment.getExternalStorageState() == Environment.MEDIA_MOUNTED) {
            Environment.getExternalStorageDirectory()
        } else {
            null
        }
    }

    fun getDownloadsDirectory(): File {
        return Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
    }

    fun getDocumentsDirectory(): File {
        return Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)
    }

    fun getPicturesDirectory(): File {
        return Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
    }

    fun getMusicDirectory(): File {
        return Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MUSIC)
    }

    fun getDirectoryContents(directory: File, showHidden: Boolean = false): List<FileItem> {
        if (!directory.exists() || !directory.isDirectory) {
            return emptyList()
        }

        return try {
            directory.listFiles()?.let { files ->
                files
                    .filter { showHidden || !it.isHidden }
                    .map { FileItem(it) }
                    .sortedWith(compareBy<FileItem> { !it.isDirectory }.thenBy { it.name.lowercase() })
            } ?: emptyList()
        } catch (e: SecurityException) {
            emptyList()
        }
    }

    fun getParentDirectory(currentPath: String): File? {
        val currentFile = File(currentPath)
        return currentFile.parentFile
    }

    fun openFileWithExternalApp(file: File): Intent? {
        return try {
            val uri = FileProvider.getUriForFile(
                context,
                "${context.packageName}.fileprovider",
                file
            )

            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, getMimeType(file))
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }

            // Verificar si hay una app que pueda manejar este intent
            if (intent.resolveActivity(context.packageManager) != null) {
                intent
            } else {
                null
            }
        } catch (e: Exception) {
            null
        }
    }

    fun readTextFile(file: File): String? {
        return try {
            if (file.exists() && file.canRead() && !file.isDirectory) {
                file.readText()
            } else {
                null
            }
        } catch (e: Exception) {
            null
        }
    }

    private fun getMimeType(file: File): String {
        return when (file.extension.lowercase()) {
            "txt", "md", "log" -> "text/plain"
            "html", "htm" -> "text/html"
            "pdf" -> "application/pdf"
            "doc" -> "application/msword"
            "docx" -> "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            "jpg", "jpeg" -> "image/jpeg"
            "png" -> "image/png"
            "gif" -> "image/gif"
            "bmp" -> "image/bmp"
            "webp" -> "image/webp"
            "mp3" -> "audio/mpeg"
            "wav" -> "audio/wav"
            "ogg" -> "audio/ogg"
            "mp4" -> "video/mp4"
            "avi" -> "video/x-msvideo"
            "mkv" -> "video/x-matroska"
            "zip" -> "application/zip"
            "rar" -> "application/x-rar-compressed"
            "7z" -> "application/x-7z-compressed"
            else -> "*/*"
        }
    }

    fun searchFiles(directory: File, query: String, showHidden: Boolean = false): List<FileItem> {
        if (!directory.exists() || !directory.isDirectory || query.isBlank()) {
            return emptyList()
        }

        val results = mutableListOf<FileItem>()

        fun searchRecursively(dir: File) {
            try {
                dir.listFiles()?.forEach { file ->
                    if (showHidden || !file.isHidden) {
                        if (file.name.contains(query, ignoreCase = true)) {
                            results.add(FileItem(file))
                        }

                        if (file.isDirectory) {
                            searchRecursively(file)
                        }
                    }
                }
            } catch (e: SecurityException) {
                // Ignorar directorios sin permisos
            }
        }

        searchRecursively(directory)
        return results.sortedWith(compareBy<FileItem> { !it.isDirectory }.thenBy { it.name.lowercase() })
    }
}