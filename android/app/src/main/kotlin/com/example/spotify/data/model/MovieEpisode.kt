package com.example.spotify.data.model
import java.io.Serializable

data class MovieEpisode(
    val url: String?,
    val localPath: String?,
    val name: String?,
    val id: String?,
    var status: Status<Int>
): Serializable
