package com.example.spotify.data.model

data class Movie(
    val id: String?,
    val name: String?,
    val slug: String?,
    val origin_name: String?,
    val type: String?,
    val poster_url: String?,
    val thumb_url: String?,
    val sub_docquyen: Boolean?,
    val chieurap: Boolean?,
    val time: String?,
    val episode_current: String?,
    val quality: String?,
    val lang: String?,
    val year: Int?,
) {
}