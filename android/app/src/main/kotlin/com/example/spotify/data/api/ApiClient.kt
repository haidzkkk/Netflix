package com.example.spotify.data.api

import com.example.spotify.AppConstants
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object ApiClient {
    private val httpClient = OkHttpClient.Builder()
        .addInterceptor(HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BODY
        })
        .build()

    private val builder = Retrofit.Builder()
        .baseUrl(AppConstants.BASE_URL)
        .client(httpClient)
        .addConverterFactory(GsonConverterFactory.create())

    private val retrofit = builder.build()
    val movieApi: MovieApi = retrofit.create(MovieApi::class.java)
}