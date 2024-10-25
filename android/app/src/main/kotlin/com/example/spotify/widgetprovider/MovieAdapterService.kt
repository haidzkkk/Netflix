package com.example.spotify.widgetprovider

import MovideAdapterFactory
import android.content.Intent
import android.widget.RemoteViewsService

class MovieAdapterService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent?): RemoteViewsFactory {
        return MovideAdapterFactory(this.applicationContext, intent!!)
    }
}