package com.example.spotify.data.repository
import android.util.Log
import com.example.spotify.data.api.MovieApi
import com.example.spotify.data.model.CategoryMovie
import com.example.spotify.data.model.MovieResponse
import com.example.spotify.data.model.MovieResponseMsg

class MovieRepository(private val movieApi: MovieApi) {

    suspend fun getMovies(categoryMovie: CategoryMovie): MovieResponse? =
        categoryMovie.typeResponse().let {type ->
            when (type) {
                MovieResponse::class.java -> movieApi.getAllMovie(categoryMovie.path, categoryMovie.slug)
                MovieResponseMsg::class.java -> movieApi.getAllMovieMsg(categoryMovie.path, categoryMovie.slug).data
                else -> {
                    Log.e("MovieRepository", "Not found type to get data")
                    null
                }
            }
        }
}
