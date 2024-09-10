package com.example.spotify

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import android.net.Uri
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import com.arthenica.mobileffmpeg.Config
import com.arthenica.mobileffmpeg.Config.RETURN_CODE_CANCEL
import com.arthenica.mobileffmpeg.Config.RETURN_CODE_SUCCESS
import com.arthenica.mobileffmpeg.FFmpeg
import com.example.spotify.AppConstants
import com.example.spotify.data.model.MovieEpisode


class DownloadService : Service() {
    override fun onBind(p0: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
    }

    var movieName: String = "";

    @SuppressLint("NewApi")
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val data = intent?.getSerializableExtra(AppConstants.DOWNLOAD_SERVICE_DATA)
        val movieEpisode: MovieEpisode? = if(data != null) (data as MovieEpisode?) else null;

        val url: String = movieEpisode?.url ?: ""
        val localPath: String = movieEpisode?.localPath ?: ""
        movieName = movieEpisode?.name ?: ""

        showNotifiForeground(0)
        downloadM3u8(url = url, localPath = localPath)
        return START_STICKY
    }

    private fun downloadM3u8(url: String, localPath: String){
        val executionId = FFmpeg.executeAsync(
            "-i $url -c:v mpeg4 -y $localPath"
        ) { _, returnCode ->
            if (returnCode == RETURN_CODE_SUCCESS) {
                showNotifi(title = "Download successfully", message = "Đã tải phim thành công")
            } else if (returnCode == RETURN_CODE_CANCEL) {
                showNotifi(title = "Download cancel", message = "Bạn đã hủy tải phim")
            } else {
                showNotifi(title = "Download failed", message = "Tải phim thất bại")
            }

            stopSelf()
        }
        val videoLength: Int = MediaPlayer.create(applicationContext, Uri.parse(url)).duration
        listenExecuteProcess(videoLength)
    }

    private fun listenExecuteProcess(videoLength: Int){
        Config.enableStatisticsCallback { newStatistics ->
            val frame = newStatistics.videoFrameNumber
            val processTime = newStatistics.time
            val executeProcess: Int = ((processTime.toDouble() / videoLength.toDouble()) * 100).toInt()
            Log.e("progress", "frame: ${frame}, current: $processTime, total: $videoLength - process: $executeProcess")
            showNotifiForeground(executeProcess)
        }
    }

    fun showNotifi(title: String, message: String){
        val notification: Notification = NotificationCompat.Builder(this, AppConstants.CHANNEL_ID)
            .setSmallIcon(R.drawable.launch_background)
            .setContentTitle(title)
            .setContentText("$movieName")
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .build()

        (getSystemService(Context.NOTIFICATION_SERVICE) as (NotificationManager))
            .notify(0, notification)
    }

    fun showNotifiForeground(executeProcess: Int){
        val notification: Notification = NotificationCompat.Builder(this, AppConstants.CHANNEL_ID)
            .setSmallIcon(R.drawable.launch_background)
            .setContentTitle("Downloading ($executeProcess%)")
            .setContentText("$movieName")
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .build()

        startForeground(1, notification)
    }
}