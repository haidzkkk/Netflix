package com.example.spotify

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PictureInPictureParams
import android.content.*
import android.content.res.Configuration
import android.os.Build
import android.util.Rational
import com.example.spotify.data.model.MovieEpisode
import com.example.spotify.data.model.Status
import com.example.spotify.widgetprovider.MovieWorker
import com.example.spotify.widgetprovider.WidgetProvider
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AppConstants.METHOD_CHANNEL_WIDGET_PROVIDER
        ).setMethodCallHandler(handleMethodWidgetProvider)

        registerChannelEvent()
        registerBroadcastReceiver()
        sendDataOpenMovieToFlutter(intent.extras?.getString(WidgetProvider.MOVIE_CLICK))
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        sendDataOpenMovieToFlutter(intent.extras?.getString(WidgetProvider.MOVIE_CLICK))
    }

    private fun registerBroadcastReceiver(){
        val intentFilter = IntentFilter().apply {
            addAction(AppConstants.ACTION_DOWNLOAD)
            addAction(AppConstants.ACTION_APPWIDGET_PINNED_SUCCESS)
        }

        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU){
            context.registerReceiver(
                registerBroadcastReceiver,
                intentFilter,
                RECEIVER_NOT_EXPORTED
            )
        }else{
            context.registerReceiver(
                registerBroadcastReceiver,
                intentFilter,
            )
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(registerBroadcastReceiver)
    }

    private var registerBroadcastReceiver = object : BroadcastReceiver(){
        override fun onReceive(context: Context?, intent: Intent?) {
            when(intent?.action){
                AppConstants.ACTION_DOWNLOAD -> {
                    val jsonData = intent.getStringExtra(AppConstants.DOWNLOAD_SERVICE_DATA)

                    if (jsonData != null && eventDownloadSink != null){
                        eventDownloadSink?.success(jsonData)
                    }
                }
                AppConstants.ACTION_APPWIDGET_PINNED_SUCCESS -> {
                    handleUpdateMovieData()
                }
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
                AppConstants.INVOKE_METHOD_START_SERVICE -> {
                    val movie = Gson().fromJson(call.arguments as String, MovieEpisode::class.java).apply {
                        this.status = Status.Initialization()
                    }
                    sendActionToDownloadService(data = movie, action = AppConstants.INVOKE_METHOD_START_SERVICE)
                    result.success("")
                    return@MethodCallHandler
                }
                AppConstants.INVOKE_METHOD_STOP_SERVICE -> {
                    stopService(Intent(this, DownloadService::class.java))
                    result.success("")
                    return@MethodCallHandler
                }
                AppConstants.INVOKE_METHOD_CANCEL_MOVIE_EPISODE -> {
                    val movie = Gson().fromJson(call.arguments as String, MovieEpisode::class.java).apply {
                        this.status = Status.Initialization()
                    }
                    sendActionToDownloadService(data = movie, action = AppConstants.INVOKE_METHOD_CANCEL_MOVIE_EPISODE)
                    result.success("")
                    return@MethodCallHandler
                }
                else ->{
                    result.notImplemented()
                }
            }
        }

    private var handleMethodWidgetProvider: MethodChannel.MethodCallHandler =
        MethodChannel.MethodCallHandler{ call, result ->
            when(call.method){
                AppConstants.INVOKE_METHOD_PROVIDE_MOVIE -> {
                    val categoryJson: String? = call.argument(AppConstants.PROVIDE_MOVIE_CATEGORY)
                    val moviesJson: String? = call.argument(AppConstants.PROVIDE_MOVIE_DATA)
                    if(moviesJson is String) WidgetProvider.updateWidgetProvider(applicationContext, categoryJson, moviesJson)
                    result.success("")
                    return@MethodCallHandler
                }
                AppConstants.INVOKE_METHOD_DRAG_WIDGET -> {
                    WidgetProvider.requestDragWidget(context)
                    result.success("")
                    return@MethodCallHandler
                }
                else ->{
                    result.notImplemented()
                }
            }
        }

    private fun sendDataOpenMovieToFlutter(movieJson: String?){
        val binaryMessenger = flutterEngine?.dartExecutor?.binaryMessenger
        if(binaryMessenger == null || movieJson == null) return

        MethodChannel(binaryMessenger, AppConstants.METHOD_CHANNEL_OPEN_MOVIE)
            .invokeMethod(AppConstants.INVOKE_METHOD_OPEN_MOVIE, movieJson)
    }

    private fun sendActionToDownloadService(data: MovieEpisode?, action: String?){
        val intent = Intent(this, DownloadService::class.java).apply {
            setAction(action)
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

    private fun handleUpdateMovieData(){
        if(WidgetProvider.isWidgetExists(context)){
            MovieWorker.startWorkPeriodic(context)
        }else{
            MovieWorker.cancelWorkPeriodic(context)
        }
    }

    fun testCall(categoryJson: String?) {
        CoroutineScope(Job() + Dispatchers.Unconfined).launch{
        }
    }
}

