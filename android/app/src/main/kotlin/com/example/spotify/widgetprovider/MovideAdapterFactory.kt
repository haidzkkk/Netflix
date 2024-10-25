import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.os.Bundle
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.bumptech.glide.Glide
import com.bumptech.glide.load.resource.bitmap.FitCenter
import com.bumptech.glide.load.resource.bitmap.RoundedCorners
import com.example.spotify.R
import com.example.spotify.data.model.Movie
import com.example.spotify.util.LocalUtil
import com.example.spotify.widgetprovider.WidgetProvider
import com.google.gson.Gson

class MovideAdapterFactory(private val context: Context, private val intent: Intent)
    : RemoteViewsService.RemoteViewsFactory {

    private var items: List<Movie> = arrayListOf()

    override fun onCreate() {
        getListData()
    }

    override fun onDataSetChanged() {
        getListData()
    }

    override fun onDestroy() {
    }

    override fun getCount(): Int {
        return items.size
    }

    override fun getViewAt(p0: Int): RemoteViews {
        val itemView = RemoteViews(context.packageName, R.layout.item_movie)
        val itemData = items[p0]
        itemView.setTextViewText(R.id.tvTitle, itemData.name)
        itemView.setTextViewText(R.id.tvDesc1, "${itemData.time ?: ""} - ${itemData.episode_current ?: ""}")
        itemView.setTextViewText(R.id.tvDesc2, itemData.lang ?: "")
        itemView.setImageViewBitmap(R.id.image_icon, getBitmapImageUrl(itemData.thumb_url ?: itemData.poster_url ?: ""))

        val intent = Intent().apply {
            putExtras(Bundle().apply {
                putString(WidgetProvider.MOVIE_CLICK, Gson().toJson(itemData))
            })
        }
        itemView.setOnClickFillInIntent(R.id.item, intent)

        return itemView
    }

    override fun getLoadingView(): RemoteViews? {
        return null
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun getItemId(p0: Int): Long {
        return p0.toLong()
    }

    override fun hasStableIds(): Boolean {
        return true
    }

    private fun getListData(){
        LocalUtil.getMovieFromLocal(context)?.apply {
            items = this
        }
    }

    private fun getBitmapImageUrl(url: String): Bitmap? {
        return try {
            Glide.with(context)
                .asBitmap()
                .load(url)
                .transform(FitCenter(), RoundedCorners(20))
                .submit(512, 512)
                .get()
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}