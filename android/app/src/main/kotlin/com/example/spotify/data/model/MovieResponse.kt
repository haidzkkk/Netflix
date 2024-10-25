package com.example.spotify.data.model

data class MovieResponseMsg(
    val status: String?,
    val msg: String?,
    val data: MovieResponse?,
)

data class MovieResponse(
    val status: Boolean?,
    val items: List<Movie>?,
)