package com.example.spotify

import android.app.Notification
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.example.spotify.data.model.MovieEpisode
import com.example.spotify.data.model.StatusEnum
import com.example.spotify.data.viewmodel.DownloadViewModel
import com.example.spotify.data.viewmodel.IEventListener


class DownloadService : Service() {
    lateinit var viewMode: DownloadViewModel

    override fun onBind(p0: Intent?): IBinder? = null

    override fun onCreate() {
        viewMode = DownloadViewModel(object: IEventListener{
            override fun onDownload(currentMovieEpisode: MovieEpisode) {
                viewMode.sendActionToActivity(applicationContext, currentMovieEpisode)
                when(currentMovieEpisode.status.status){
                    StatusEnum.LOADING -> {
                        showNotifyForeground(
                            title = "${currentMovieEpisode.status.data} (${currentMovieEpisode.executeProcess}%)",
                            message = currentMovieEpisode.movieName ?: ""
                        )
                    }
                    StatusEnum.SUCCESS -> {
                        showNotify(
                            title = currentMovieEpisode.status.data ?: "",
                            message = currentMovieEpisode.movieName ?: ""
                        )
                    }
                    StatusEnum.ERROR -> {
                        showNotify(
                            title = currentMovieEpisode.status.data ?: "",
                            message = currentMovieEpisode.movieName ?: ""
                        )
                    }
                    else -> {
                        showNotifyForeground()
                    }
                }
            }

            override fun onDownloaded() {
                stopSelf()
            }
        })
        super.onCreate()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val data = intent?.getSerializableExtra(AppConstants.DOWNLOAD_SERVICE_DATA)
        val movieEpisode: MovieEpisode? = if(data != null) (data as MovieEpisode?) else null

        if(movieEpisode != null){
            viewMode.setData(applicationContext, movieEpisode)
        }
        showNotifyForeground()
        return START_STICKY
    }

    fun showNotify(title: String, message: String){
        val notification: Notification = NotificationCompat.Builder(this, AppConstants.CHANNEL_ID)
            .setSmallIcon(R.mipmap.app_icon)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .build()

        (getSystemService(Context.NOTIFICATION_SERVICE) as (NotificationManager))
            .notify(0, notification)
    }

    fun showNotifyForeground(
        title: String = "Đang chạy dịch vụ download",
        message: String = "Không có phim để tải"
    ){
        val notification: Notification = NotificationCompat.Builder(this, AppConstants.CHANNEL_ID)
            .setSmallIcon(R.mipmap.app_icon)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .build()

        startForeground(1, notification)
    }
}