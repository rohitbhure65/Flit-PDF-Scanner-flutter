package com.flitpdfscanner.flitpdf

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageDecoder
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import kotlin.math.max
import kotlin.math.roundToInt

class MainActivity : FlutterActivity() {
    private val scannerFilesChannel = "flitpdf/scanner_files"
    private val defaultMaxLongSide = 2200
    private val defaultJpegQuality = 82

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, scannerFilesChannel)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "persistUrisToCache" -> {
                            val uris = call.argument<List<String>>("uris").orEmpty()
                            val maxLongSide =
                                    call.argument<Int>("maxLongSide") ?: defaultMaxLongSide
                            val jpegQuality =
                                    call.argument<Int>("jpegQuality") ?: defaultJpegQuality
                            try {
                                result.success(
                                        persistUrisToCache(
                                                uris = uris,
                                                maxLongSide = maxLongSide,
                                                jpegQuality = jpegQuality
                                        )
                                )
                            } catch (e: Exception) {
                                result.error(
                                        "CACHE_PERSIST_FAILED",
                                        e.message ?: "Unable to persist scanned files",
                                        null
                                )
                            }
                        }
                        "persistImagesToCache" -> {
                            val paths = call.argument<List<String>>("paths").orEmpty()
                            val maxLongSide =
                                    call.argument<Int>("maxLongSide") ?: defaultMaxLongSide
                            val jpegQuality =
                                    call.argument<Int>("jpegQuality") ?: defaultJpegQuality
                            try {
                                result.success(
                                        persistImagesToCache(
                                                paths = paths,
                                                maxLongSide = maxLongSide,
                                                jpegQuality = jpegQuality
                                        )
                                )
                            } catch (e: Exception) {
                                result.error(
                                        "CACHE_PERSIST_FAILED",
                                        e.message ?: "Unable to persist scanned files",
                                        null
                                )
                            }
                        }
                        else -> result.notImplemented()
                    }
                }
    }

    private fun persistUrisToCache(
            uris: List<String>,
            maxLongSide: Int,
            jpegQuality: Int
    ): List<String> {
        val batchId = System.currentTimeMillis()
        return uris.mapIndexedNotNull { index, rawUri ->
            persistImageToCache(
                    rawSource = rawUri,
                    filePrefix = "scanned_page_${batchId}",
                    index = index,
                    maxLongSide = maxLongSide,
                    jpegQuality = jpegQuality
            )
        }
    }

    private fun persistImagesToCache(
            paths: List<String>,
            maxLongSide: Int,
            jpegQuality: Int
    ): List<String> {
        val batchId = System.currentTimeMillis()
        return paths.mapIndexedNotNull { index, rawPath ->
            persistImageToCache(
                    rawSource = rawPath,
                    filePrefix = "gallery_page_${batchId}",
                    index = index,
                    maxLongSide = maxLongSide,
                    jpegQuality = jpegQuality
            )
        }
    }

    private fun persistImageToCache(
            rawSource: String,
            filePrefix: String,
            index: Int,
            maxLongSide: Int,
            jpegQuality: Int
    ): String? {
        try {
            val sourceUri = toUri(rawSource)
            val bitmap = decodeBitmap(sourceUri) ?: return null
            val resizedBitmap = resizeBitmap(bitmap, maxLongSide)
            val file = File(cacheDir, "${filePrefix}_$index.jpg")

            try {
                file.outputStream().use { outputStream ->
                    resizedBitmap.compress(
                            Bitmap.CompressFormat.JPEG,
                            jpegQuality.coerceIn(0, 100),
                            outputStream
                    )
                }
            } finally {
                if (resizedBitmap !== bitmap) {
                    resizedBitmap.recycle()
                }
                bitmap.recycle()
            }

            return file.absolutePath
        } catch (_: Exception) {
            return null
        }
    }

    private fun toUri(rawSource: String): Uri {
        return when {
            rawSource.startsWith("content://") || rawSource.startsWith("file://") ->
                    Uri.parse(rawSource)
            else -> Uri.fromFile(File(rawSource))
        }
    }

    private fun decodeBitmap(uri: Uri): Bitmap? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val source = ImageDecoder.createSource(contentResolver, uri)
            ImageDecoder.decodeBitmap(source) { decoder, _, _ -> decoder.isMutableRequired = false }
        } else {
            contentResolver.openInputStream(uri)?.use { inputStream ->
                BitmapFactory.decodeStream(inputStream)
            }
        }
    }

    private fun resizeBitmap(bitmap: Bitmap, maxLongSide: Int): Bitmap {
        val safeMaxLongSide = maxLongSide.coerceAtLeast(1)
        val longestSide = max(bitmap.width, bitmap.height)
        if (longestSide <= safeMaxLongSide) {
            return bitmap
        }

        val scale = safeMaxLongSide.toFloat() / longestSide.toFloat()
        val targetWidth = max(1, (bitmap.width * scale).roundToInt())
        val targetHeight = max(1, (bitmap.height * scale).roundToInt())
        return Bitmap.createScaledBitmap(bitmap, targetWidth, targetHeight, true)
    }
}
