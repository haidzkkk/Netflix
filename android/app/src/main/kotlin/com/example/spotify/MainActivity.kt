package com.example.spotify

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.util.Log
import com.example.spotify.data.model.MovieEpisode
import com.example.spotify.data.model.Status
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        createChannelNotify()

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AppConstants.METHOD_CHANNEL_DOWNLOAD
        ).setMethodCallHandler(handleMethodDownload)

        registerChannelEvent()
    }
    override fun onResume() {
        super.onResume()
        context.registerReceiver(broadcastRegister, IntentFilter(AppConstants.ACTION_COMMUNICATE))
    }

    override fun onPause() {
        super.onPause()
        unregisterReceiver(broadcastRegister)
    }
    override fun onDestroy() {
        unregisterReceiver(broadcastRegister)
        super.onDestroy()
    }

    private var broadcastRegister = object : BroadcastReceiver(){
        override fun onReceive(context: Context?, intent: Intent?) {
            val jsonData = intent?.getStringExtra(AppConstants.DOWNLOAD_SERVICE_DATA)

            if (jsonData != null && eventSink != null){
                eventSink?.success(jsonData)
            }
        }
    }
    private var eventSink: EventChannel.EventSink? = null
    private fun registerChannelEvent(){
        EventChannel(flutterEngine?.dartExecutor?.binaryMessenger, AppConstants.METHOD_EVENT_DOWNLOAD).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
    }

    private var handleMethodDownload: MethodChannel.MethodCallHandler =
        MethodChannel.MethodCallHandler{ call, result ->
            when(call.method){
                AppConstants.METHOD_CHANNEL_START_SERVICE -> {
                    val movie = Gson().fromJson(call.arguments as String, MovieEpisode::class.java).apply {
                        this.status = Status.Initialization()
                    }
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

