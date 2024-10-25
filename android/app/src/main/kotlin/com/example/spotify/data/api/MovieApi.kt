package com.example.spotify.data.api

import com.example.spotify.data.model.MovieResponse
import com.example.spotify.data.model.MovieResponseMsg
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query

interface MovieApi {

    @GET("{path}/{slug}")
    suspend fun getAllMovie(
        @Path("path", encoded = true) path: String,
        @Path("slug", encoded = true) slug: String,
        @Query("page") page: Int = 1
    ): MovieResponse

    @GET("{path}/{slug}")
    suspend fun getAllMovieMsg(
        @Path("path", encoded = true) path: String,
        @Path("slug", encoded = true) slug: String,
        @Query("page") page: Int = 1
    ): MovieResponseMsg
}