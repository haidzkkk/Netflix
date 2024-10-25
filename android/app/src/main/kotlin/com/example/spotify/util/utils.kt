package com.example.spotify.util

import android.app.PendingIntent
import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import com.example.spotify.AppConstants
import com.example.spotify.data.model.CategoryMovie
import com.example.spotify.data.model.Movie
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import io.flutter.embedding.android.FlutterActivity
import java.lang.reflect.Type

class LocalUtil{
    companion object {
        fun mySharedPreferences(context: Context): SharedPreferences = context.getSharedPreferences(
            AppConstants.SHARED_PREFERENCES_ID,
            FlutterActivity.MODE_PRIVATE
        )

        fun putCategoryToLocal(context: Context, categoryJson: String): Boolean =
            try {
                Gson().fromJson(categoryJson, CategoryMovie::class.java)
                mySharedPreferences(context).edit().apply {
                    putString(AppConstants.CATEGORY_KEY, categoryJson)
                }.apply()
                true
            }catch (e: Exception){
                false
            }

        fun getCategoryFromLocal(context: Context): CategoryMovie? = mySharedPreferences(context)
            .getString(AppConstants.CATEGORY_KEY, null)?.let { json ->
                Gson().fromJson(json, CategoryMovie::class.java)
            }

        fun putMovieToLocal(context: Context, moviesJson: String): Boolean =
            try {
                val listType: Type = object : TypeToken<List<Movie>>() {}.type
                Gson().fromJson<List<Movie>>(moviesJson, listType)
                mySharedPreferences(context).edit().apply {
                    putString(AppConstants.MOVIE_KEY, moviesJson)
                }.apply()
                true
            }catch (e: Exception){
                false
            }

        fun getMovieFromLocal(context: Context): List<Movie>? = mySharedPreferences(context)
            .getString(AppConstants.MOVIE_KEY, null)?.let { json ->
                val listType: Type = object : TypeToken<List<Movie?>?>() {}.type
                Gson().fromJson(json, listType)
            }
    }
}


fun getFlagPendingIntent() = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
    }else{
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE // this flag not receiver with data
    }
