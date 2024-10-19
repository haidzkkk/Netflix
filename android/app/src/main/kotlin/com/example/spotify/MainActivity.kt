package com.example.spotify

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PictureInPictureParams
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import android.os.Build
import android.util.Log
import android.util.Rational
import com.example.spotify.data.model.MovieEpisode
import com.example.spotify.data.model.Status
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private lateinit var builderParams: PictureInPictureParams.Builder

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        createChannelNotify()
        setupPip()
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AppConstants.METHOD_CHANNEL_DOWNLOAD
        ).setMethodCallHandler(handleMethodDownload)

        registerChannelEvent()
    }

    override fun onResume() {
        super.onResume()
        if(!isReceiverRegistered){
            isReceiverRegistered = true
            if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU){
                context.registerReceiver(
                    broadcastRegister,
                    IntentFilter(AppConstants.ACTION_COMMUNICATE),
                    RECEIVER_NOT_EXPORTED
                )
            }else{
                context.registerReceiver(
                    broadcastRegister,
                    IntentFilter(AppConstants.ACTION_COMMUNICATE),
                )
            }
        }
    }

    override fun onPause() {
        super.onPause()
        if(isReceiverRegistered){
            unregisterReceiver(broadcastRegister)
            isReceiverRegistered = false;
        }
    }
    override fun onDestroy() {
        super.onDestroy()
        if(isReceiverRegistered){
            unregisterReceiver(broadcastRegister)
            isReceiverRegistered = false;
        }
    }

    private var isReceiverRegistered = false
    private var broadcastRegister = object : BroadcastReceiver(){
        override fun onReceive(context: Context?, intent: Intent?) {
            val jsonData = intent?.getStringExtra(AppConstants.DOWNLOAD_SERVICE_DATA)

            if (jsonData != null && eventDownloadSink != null){
                eventDownloadSink?.success(jsonData)
            }
        }
    }

    private var eventDownloadSink: EventChannel.EventSink? = null
    private var eventPipSink: EventChannel.EventSink? = null
    private fun registerChannelEvent(){
        EventChannel(flutterEngine?.dartExecutor?.binaryMessenger, AppConstants.METHOD_EVENT_DOWNLOAD).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventDownloadSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventDownloadSink = null
                }
            }
        )

        EventChannel(flutterEngine?.dartExecutor?.binaryMessenger, AppConstants.METHOD_EVENT_PIP).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventPipSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventPipSink = null
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

    private fun setupPip() {
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            builderParams = PictureInPictureParams.Builder()
            val aspectRation = Rational(1920, 1080)
            builderParams.apply {
                setAspectRatio(aspectRation)
            }
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        openPipMode()
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration?
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        if(isInPictureInPictureMode){
            eventPipSink?.success(1)
        }else{
            eventPipSink?.success(0)
        }
    }

    private fun openPipMode(){
        if(Build.VERSION.SDK_INT < Build.VERSION_CODES.O
            || isInPictureInPictureMode
            || eventPipSink == null
        ) return

        enterPictureInPictureMode(builderParams.build())
    }
}

