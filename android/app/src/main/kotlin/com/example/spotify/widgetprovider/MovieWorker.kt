package com.example.spotify.widgetprovider

import android.content.Context
import android.util.Log
import androidx.work.*
import com.example.spotify.data.api.ApiClient
import com.example.spotify.data.model.CategoryMovie
import com.example.spotify.data.repository.MovieRepository
import com.example.spotify.util.LocalUtil
import com.google.gson.Gson
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.concurrent.TimeUnit

class MovieWorker(private val context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
    private val movieRepository = MovieRepository(ApiClient.movieApi)

    override suspend fun doWork(): Result {
        Log.e("Worker: ${Thread.currentThread().name}", "Start work background")

        val categoryMovie: CategoryMovie? = LocalUtil.getCategoryFromLocal(context)
        if(categoryMovie == null){
            cancelWorkPeriodic(context)
            return Result.failure()
        }

        return withContext(Dispatchers.IO){
            try{
                val listMovie = movieRepository.getMovies(categoryMovie)
                val movieJson = Gson().toJson(listMovie?.items)
                WidgetProvider.updateWidgetProvider(context, movieJson = movieJson)
                Result.success()
            }catch (e: Exception){
                Result.failure()
            }
        }
    }

    companion object{
        private const val workName = "PeriodicWorkMovie"

        fun startWorkPeriodic(context: Context, secondDuration: Long? = null){
            val workConstraint = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.UNMETERED)
                .build()
            val workRequest = PeriodicWorkRequestBuilder<MovieWorker>(
                secondDuration ?: 15, TimeUnit.MINUTES)
                .setConstraints(workConstraint)
                .build()

            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                workName,
                ExistingPeriodicWorkPolicy.UPDATE,
                workRequest
            )
        }

        fun cancelWorkPeriodic(context: Context){
            WorkManager.getInstance(context).cancelUniqueWork(workName)
        }
    }
}