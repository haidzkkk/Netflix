package com.example.spotify.widgetprovider

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import androidx.core.content.ContextCompat.getSystemService
import com.example.spotify.AppConstants
import com.example.spotify.MainActivity
import com.example.spotify.R
import com.example.spotify.data.model.CategoryMovie
import com.example.spotify.data.model.MovieEpisode
import com.example.spotify.util.LocalUtil
import com.example.spotify.util.getFlagPendingIntent
import com.google.gson.Gson

class WidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context?,
        appWidgetManager: AppWidgetManager?,
        appWidgetIds: IntArray?
    ) {
        if(context != null) appWidgetIds?.forEach { widgetId ->
            val remoteView = RemoteViews(context.packageName, R.layout.list_widget_provider)

            // title
            val category: CategoryMovie? = LocalUtil.getCategoryFromLocal(context)
            remoteView.setTextViewText(R.id.title, category?.name ?: titleNone)
            remoteView.setOnClickPendingIntent(R.id.title, PendingIntent.getActivity(
                context,0,
                Intent(context, MainActivity::class.java),
                getFlagPendingIntent()
            ))

            val hasMovieData: Boolean = LocalUtil.mySharedPreferences(context).getString(AppConstants.MOVIE_KEY, null) is String
            if(hasMovieData){
                remoteView.setViewVisibility(R.id.listview, View.VISIBLE)
                remoteView.setViewVisibility(R.id.tvNone, View.INVISIBLE)
            }else{
                remoteView.setViewVisibility(R.id.listview, View.INVISIBLE)
                remoteView.setViewVisibility(R.id.tvNone, View.VISIBLE)
            }

            // list
            remoteView.setRemoteAdapter(
                R.id.listview,
                Intent(context, MovieAdapterService::class.java)
            )
            remoteView.setPendingIntentTemplate(
                R.id.listview,
                PendingIntent.getBroadcast(
                    context,
                    0,
                    Intent(context, WidgetProvider::class.java).apply { action = AppConstants.ACTION_CLICK },
                    getFlagPendingIntent()
                )
            )

            appWidgetManager?.updateAppWidget(widgetId, remoteView)
        }
        super.onUpdate(context, appWidgetManager, appWidgetIds)
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        when(intent?.action){
            // when user click from widget pin
           AppConstants.ACTION_CLICK ->{
                val data = intent.extras
                val activityIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtras(Bundle().apply {
                        putString(MOVIE_CLICK, data?.getString(MOVIE_CLICK))
                        putInt(AppWidgetManager.EXTRA_APPWIDGET_ID, data?.getInt(AppWidgetManager.EXTRA_APPWIDGET_ID) ?: -1)
                    })
                }
                context?.startActivity(activityIntent)
            }
            AppConstants.ACTION_APPWIDGET_PINNED ->{
                context?.apply {
                    Log.e("WidgetProvider", "onReceive ACTION_APPWIDGET_PINNED")
                    val myIntent = Intent(AppConstants.ACTION_APPWIDGET_PINNED_SUCCESS)
                    myIntent.setPackage(context.packageName)
                    sendBroadcast(myIntent)
                }

            }
            else ->{
                super.onReceive(context, intent)
            }
        }
    }

    companion object{
        const val titleNone = "Không có thể loại"

        var MOVIE_CLICK = "movie"

        fun requestDragWidget(context: Context){
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val mAppWidgetManager = getSystemService(context, AppWidgetManager::class.java)
                val myProvider = ComponentName(context, WidgetProvider::class.java)

                val successIntent = PendingIntent.getBroadcast(
                    context,
                    0,
                    Intent(context, WidgetProvider::class.java).apply {
                        action = AppConstants.ACTION_APPWIDGET_PINNED
                    },
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                if (mAppWidgetManager?.isRequestPinAppWidgetSupported == true) {
                    mAppWidgetManager.requestPinAppWidget(myProvider, null, successIntent)
                }
            }
        }

        fun isWidgetExists(context: Context): Boolean{
            val widgetProvider = ComponentName(context, WidgetProvider::class.java)
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val idsWidget = appWidgetManager.getAppWidgetIds(widgetProvider)
            return idsWidget.isNotEmpty()
        }

        fun updateWidgetProvider(context: Context, categoryJson: String? = null, movieJson: String){
            val widgetProvider = ComponentName(context, WidgetProvider::class.java)
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val idsWidget = appWidgetManager.getAppWidgetIds(widgetProvider)

            // save data to local -> factory get to use
            if(categoryJson != null) LocalUtil.putCategoryToLocal(context, categoryJson)
            if(idsWidget.isEmpty()) return
            LocalUtil.putMovieToLocal(context, movieJson)


            val remoteView = RemoteViews(context.packageName, R.layout.list_widget_provider)

            val category: CategoryMovie? = LocalUtil.getCategoryFromLocal(context)
            remoteView.setTextViewText(R.id.title, category?.name ?: titleNone)

            remoteView.setViewVisibility(R.id.listview, View.VISIBLE)
            remoteView.setViewVisibility(R.id.tvNone, View.INVISIBLE)

            for(id in idsWidget){
                appWidgetManager?.updateAppWidget(id, remoteView)
                appWidgetManager.notifyAppWidgetViewDataChanged(id, R.id.listview)
            }
        }
    }
}