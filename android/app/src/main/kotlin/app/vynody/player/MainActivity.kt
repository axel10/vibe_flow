package app.vynody.player

import android.content.Context
import android.content.Intent
import android.database.ContentObserver
import android.net.Uri
import android.os.Bundle
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.provider.OpenableColumns
import android.provider.Settings
import android.util.Log
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.Executors

class MainActivity : AudioServiceActivity() {
    private val TAG = "MainActivity"
    private val MEDIA_OBSERVER_CHANNEL = "app.vynody.player/media_observer"
    private val BATTERY_CHANNEL = "app.vynody.player/battery"
    private val FILE_OPENER_CHANNEL = "vynody/file_opener"

    private var eventSink: EventChannel.EventSink? = null
    private var contentObserver: ContentObserver? = null
    private var fileOpenerChannel: MethodChannel? = null
    private val pendingFiles = mutableListOf<String>()
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        intent?.let { handleIntent(it) }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val fileChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FILE_OPENER_CHANNEL)
        fileOpenerChannel = fileChannel
        fileChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getPendingFiles" -> {
                    synchronized(pendingFiles) {
                        val files = ArrayList(pendingFiles)
                        pendingFiles.clear()
                        Log.d(TAG, "getPendingFiles returning $files")
                        result.success(files)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // If there were any pending files resolved before Flutter registered, send them now
        synchronized(pendingFiles) {
            if (pendingFiles.isNotEmpty()) {
                val files = ArrayList(pendingFiles)
                pendingFiles.clear()
                fileChannel.invokeMethod("onOpenFiles", files)
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, MEDIA_OBSERVER_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    registerMediaObserver()
                }

                override fun onCancel(arguments: Any?) {
                    unregisterMediaObserver()
                    eventSink = null
                }
            })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openBatterySettings" -> {
                        try {
                            val intent = Intent().apply {
                                action = Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("ERROR", e.message, null)
                        }
                    }
                    "requestIgnoreBatteryOptimizations" -> {
                        try {
                            val intent = Intent().apply {
                                action = Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
                                data = Uri.parse("package:$packageName")
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("ERROR", e.message, null)
                        }
                    }
                    "openAppSettings" -> {
                        try {
                            val intent = Intent().apply {
                                action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                                data = Uri.parse("package:$packageName")
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun registerMediaObserver() {
        if (contentObserver != null) return

        val handler = Handler(Looper.getMainLooper())
        contentObserver = object : ContentObserver(handler) {
            override fun onChange(selfChange: Boolean, uri: Uri?) {
                super.onChange(selfChange, uri)
                // Avoid flooding with multiple changes in short time
                handler.removeCallbacksAndMessages(null)
                handler.postDelayed({
                    eventSink?.success("media_changed")
                }, 1000)
            }
        }

        try {
            contentResolver.registerContentObserver(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                true,
                contentObserver!!
            )
        } catch (e: Exception) {
            // Log error or notify flutter if needed
        }
    }

    private fun unregisterMediaObserver() {
        contentObserver?.let {
            contentResolver.unregisterContentObserver(it)
            contentObserver = null
        }
    }

    private fun handleIntent(intent: Intent) {
        val action = intent.action ?: return
        if (action != Intent.ACTION_VIEW && action != Intent.ACTION_SEND && action != Intent.ACTION_EDIT) {
            return
        }

        val uris = mutableListOf<Uri>()
        intent.data?.let { uris.add(it) }

        if (action == Intent.ACTION_SEND) {
            val streamUri = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
            } else {
                @Suppress("DEPRECATION")
                intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
            }
            if (streamUri != null && !uris.contains(streamUri)) {
                uris.add(streamUri)
            }
        }

        val clipData = intent.clipData
        if (clipData != null) {
            for (i in 0 until clipData.itemCount) {
                val itemUri = clipData.getItemAt(i).uri
                if (itemUri != null && !uris.contains(itemUri)) {
                    uris.add(itemUri)
                }
            }
        }

        if (uris.isEmpty()) return

        Log.d(TAG, "handleIntent: found ${uris.size} uris, processing...")
        executor.execute {
            val resolvedPaths = ArrayList<String>()
            for (uri in uris) {
                try {
                    val path = resolveUriToPath(uri)
                    if (path != null && path.isNotBlank()) {
                        resolvedPaths.add(path)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Failed resolving uri $uri", e)
                }
            }

            if (resolvedPaths.isNotEmpty()) {
                mainHandler.post {
                    Log.d(TAG, "handleIntent: dispatching resolved paths: $resolvedPaths")
                    val channel = fileOpenerChannel
                    if (channel != null) {
                        channel.invokeMethod("onOpenFiles", resolvedPaths)
                    } else {
                        synchronized(pendingFiles) {
                            pendingFiles.addAll(resolvedPaths)
                        }
                    }
                }
            }
        }
    }

    private fun resolveUriToPath(uri: Uri): String? {
        Log.d(TAG, "resolveUriToPath: uri=$uri, scheme=${uri.scheme}, auth=${uri.authority}")

        if (uri.scheme == "file") {
            val filePath = uri.path ?: return null
            val file = File(filePath)
            if (file.exists() && file.canRead()) {
                return file.absolutePath
            }
            return filePath
        }

        if (uri.scheme == "content") {
            // 1. SAF Document Uri
            if (DocumentsContract.isDocumentUri(this, uri)) {
                if (uri.authority == "com.android.externalstorage.documents") {
                    val docId = DocumentsContract.getDocumentId(uri)
                    val split = docId.split(":")
                    if (split.isNotEmpty()) {
                        val type = split[0]
                        val relPath = if (split.size > 1) split[1] else ""
                        val file = if (type.equals("primary", ignoreCase = true)) {
                            File(Environment.getExternalStorageDirectory(), relPath)
                        } else {
                            File("/storage/$type/$relPath")
                        }
                        if (file.exists() && file.canRead()) {
                            return file.absolutePath
                        }
                    }
                } else if (uri.authority == "com.android.providers.media.documents") {
                    val docId = DocumentsContract.getDocumentId(uri)
                    val split = docId.split(":")
                    val id = if (split.size > 1) split[1] else docId
                    try {
                        val cursor = contentResolver.query(
                            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                            arrayOf(MediaStore.Audio.Media.DATA),
                            "${MediaStore.Audio.Media._ID}=?",
                            arrayOf(id),
                            null
                        )
                        cursor?.use {
                            if (it.moveToFirst()) {
                                val idx = it.getColumnIndex(MediaStore.Audio.Media.DATA)
                                if (idx != -1) {
                                    val dataPath = it.getString(idx)
                                    if (!dataPath.isNullOrBlank() && File(dataPath).exists()) {
                                        return dataPath
                                    }
                                }
                            }
                        }
                    } catch (e: Exception) {
                        Log.w(TAG, "Failed resolving media document: ${e.message}")
                    }
                }
            }

            // 2. Direct MediaStore query
            if (uri.authority?.contains("media") == true) {
                try {
                    val cursor = contentResolver.query(
                        uri,
                        arrayOf(MediaStore.Audio.Media.DATA),
                        null,
                        null,
                        null
                    )
                    cursor?.use {
                        if (it.moveToFirst()) {
                            val idx = it.getColumnIndex(MediaStore.Audio.Media.DATA)
                            if (idx != -1) {
                                val dataPath = it.getString(idx)
                                if (!dataPath.isNullOrBlank() && File(dataPath).exists()) {
                                    return dataPath
                                }
                            }
                        }
                    }
                } catch (e: Exception) {
                    Log.w(TAG, "Direct MediaStore query failed: ${e.message}")
                }
            }

            // 3. Check if path string contains direct storage path
            val decoded = Uri.decode(uri.toString())
            val storageIndex = decoded.indexOf("/storage/")
            if (storageIndex != -1) {
                val candidatePath = decoded.substring(storageIndex)
                val candidateFile = File(candidatePath)
                if (candidateFile.exists() && candidateFile.canRead()) {
                    return candidateFile.absolutePath
                }
            }

            // 4. Fallback: Copy content stream to cacheDir/external_opened
            var displayName: String? = null
            try {
                val cursor = contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
                cursor?.use {
                    if (it.moveToFirst()) {
                        val idx = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                        if (idx != -1) {
                            displayName = it.getString(idx)
                        }
                    }
                }
            } catch (e: Exception) {
                Log.w(TAG, "Query displayName failed: ${e.message}")
            }

            if (displayName.isNullOrBlank()) {
                val lastSeg = uri.lastPathSegment ?: "unknown"
                displayName = if (lastSeg.contains(".")) lastSeg else "song_${System.currentTimeMillis()}.mp3"
            }

            val cacheFolder = File(cacheDir, "external_opened")
            if (!cacheFolder.exists()) {
                cacheFolder.mkdirs()
            }
            val destFile = File(cacheFolder, displayName)
            try {
                contentResolver.openInputStream(uri)?.use { input ->
                    FileOutputStream(destFile).use { output ->
                        input.copyTo(output)
                    }
                }
                if (destFile.exists() && destFile.length() > 0) {
                    return destFile.absolutePath
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed caching content uri to file: ${e.message}", e)
            }
        }

        return null
    }

    override fun onDestroy() {
        executor.shutdown()
        unregisterMediaObserver()
        super.onDestroy()
    }
}
