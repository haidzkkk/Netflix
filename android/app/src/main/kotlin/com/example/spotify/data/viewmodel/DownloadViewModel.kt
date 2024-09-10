package com.example.spotify.data.viewmodel

import android.content.Context
import android.media.MediaPlayer
import android.net.Uri
import android.util.Log
import com.arthenica.mobileffmpeg.Config
import com.arthenica.mobileffmpeg.FFmpeg
import com.example.spotify.data.model.MovieEpisode
import com.example.spotify.data.model.Status
import java.util.*

interface IEventListener{
    fun onDownload(currentMovieEpisode: MovieEpisode)
    fun onDownloaded()
}

class DownloadViewModel(private val listener: IEventListener
) {

    private val listMovie: Queue<MovieEpisode> = LinkedList()
    private var currentMovie: MovieEpisode? = null

    fun setData(applicationContext: Context, movie: MovieEpisode){
        calculateTimeDownloadMovie(applicationContext, movie)
        listMovie.add(movie)
        if(currentMovie != null) return     /// if downloading -> return

        startDownload()
    }

    init {
        listenDownloadExecuteProcess()
    }

    private fun startDownload(){
        currentMovie = listMovie.poll()
        if(currentMovie == null) {
            listener.onDownloaded()
            return
        }

        FFmpeg.executeAsync(
            "-i ${currentMovie!!.url} -c:v mpeg4 -y ${currentMovie!!.localPath}"
        ) { _, returnCode ->
            if (returnCode == Config.RETURN_CODE_SUCCESS) {
                listener.onDownload(
                    currentMovie!!.apply {
                        status = Status.Success("Download completed successfully")
                    }
                )
            } else {
                listener.onDownload(
                    currentMovie!!.apply {
                        status = if (returnCode == Config.RETURN_CODE_CANCEL)
                                    Status.Success("Download canceled")
                                else Status.Success("Download failed")
                    }
                )
            }
            startDownload()
        }
    }

    private fun calculateTimeDownloadMovie(applicationContext: Context, movieEpisode: MovieEpisode){
        val url = movieEpisode.url
        if (url.isNullOrEmpty()) {
            return
        }
        val mediaPlayer: MediaPlayer = MediaPlayer.create(applicationContext, Uri.parse(url))
        movieEpisode.totalSecondTime = mediaPlayer.duration
        mediaPlayer.release()
    }

    private fun listenDownloadExecuteProcess(){
        Config.enableStatisticsCallback { newStatistics ->
            if(currentMovie == null) return@enableStatisticsCallback

            currentMovie!!.currentSecondTime = newStatistics.time
            Log.e("progress", "current: ${currentMovie!!.currentSecondTime}, total: $${currentMovie!!.totalSecondTime} - process: $${currentMovie!!.getExecuteProcessDownload()}")
            listener.onDownload(
                currentMovie!!.apply {
                    status = Status.Loading("Downloading")
                }
            )
        }
    }
}