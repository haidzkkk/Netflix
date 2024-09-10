package com.example.spotify.data.model
import java.io.Serializable

data class MovieEpisode(
    val url: String?,
    val localPath: String?,
    val name: String?,
    val id: String?,
    var status: Status<String>
): Serializable{
    var totalSecondTime: Int = 0
    var currentSecondTime: Int = 0

    fun getExecuteProcessDownload(): Int {
        if (currentSecondTime < 0) {
            currentSecondTime = 0
        } else if (currentSecondTime > totalSecondTime) {
            currentSecondTime = totalSecondTime
        }
        return ((currentSecondTime.toDouble() / (totalSecondTime).toDouble()) * 100).toInt()
    }
}
