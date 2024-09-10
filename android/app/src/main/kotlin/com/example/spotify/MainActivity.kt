package com.example.spotify

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.os.Build
import android.os.Bundle
import com.example.spotify.data.model.MovieEpisode
import com.example.spotify.data.model.Status
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        createChannelNotify()

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AppConstants.METHOD_CHANNEL_DOWNLOAD
        ).setMethodCallHandler(handleMethodDownload)
    }

    private var handleMethodDownload: MethodChannel.MethodCallHandler =
        MethodChannel.MethodCallHandler{ call, result ->
            when(call.method){
                AppConstants.METHOD_CHANNEL_START_SERVICE -> {
                    val movie: MovieEpisode = MovieEpisode(
                        id = call.argument(AppConstants.METHOD_CHANNEL_ARGUMENT_ID),
                        name = call.argument(AppConstants.METHOD_CHANNEL_ARGUMENT_MOVIE_NAME),
                        url = call.argument(AppConstants.METHOD_CHANNEL_ARGUMENT_URL),
                        localPath = call.argument(AppConstants.METHOD_CHANNEL_ARGUMENT_LOCAL_PATH),
                        status = Status.Initialization(),
                    )
                    sendActionToDownloadService(data = movie)

                    return@MethodCallHandler
                }
                AppConstants.METHOD_CHANNEL_STOP_SERVICE -> {
                    stopService(Intent(this, DownloadService::class.java))
                    return@MethodCallHandler
                }
                else ->{
                    result.notImplemented()
                }
            }
        }

    private fun sendActionToDownloadService(data: MovieEpisode){

        val intent = Intent(this, DownloadService::class.java).apply {
            putExtra(AppConstants.DOWNLOAD_SERVICE_DATA, data)
        }
        startService(intent)
    }

    private fun createChannelNotify() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val notificationManager = getSystemService(NotificationManager::class.java) as NotificationManager

        val channel1 = NotificationChannel(AppConstants.CHANNEL_ID, "CHANNEL_NAME", NotificationManager.IMPORTANCE_DEFAULT)
        channel1.setSound(null, null)
        notificationManager.createNotificationChannel(channel1)
    }
}

