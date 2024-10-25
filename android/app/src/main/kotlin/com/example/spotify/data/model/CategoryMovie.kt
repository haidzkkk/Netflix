package com.example.spotify.data.model

import com.example.spotify.AppConstants

data class CategoryMovie(val name: String, val slug: String, val path: String) {
    fun typeResponse(): Class<*>? {
        return when (slug) {
            "phim-moi-cap-nhat" -> {
                MovieResponse::class.java
            }
            "hoat-hinh", "phim-le", "tv-shows", "phim-bo", "hanh-dong", "tinh-cam" -> {
                MovieResponseMsg::class.java
            }
            else -> null
        }
    }

}