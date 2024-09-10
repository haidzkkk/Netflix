package com.example.spotify.data.viewmodel

import com.example.spotify.data.model.MovieEpisode
import java.util.*

class DownloadViewModel {
    val listMovie: Queue<MovieEpisode> = LinkedList()
    var currentMovie: MovieEpisode? = null;

    public fun startDownload(movie: MovieEpisode){
        listMovie.add(movie)
        if(currentMovie != null) return

        currentMovie = listMovie.poll()


    }
}