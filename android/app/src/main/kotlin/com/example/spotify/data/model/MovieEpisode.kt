package com.example.spotify.data.model
import java.io.Serializable

data class MovieEpisode(
    val url: String?,
    val localPath: String?,
    val movieId: String?,
    val movieName: String?,
    val movieSlug: String?,
    val name: String?,
    val slug: String?,
    val id: String?,
    var status: Status<String>,
    var serverType: String?,
): Serializable{
    var executeProcess: Int = 0
    var totalSecondTime: Int = 0
        set(value) {
            field = value
            calculateExecuteProcess()
        }
    var currentSecondTime: Int = 0
        set(value) {
            field = value
            calculateExecuteProcess()
        }
    private fun calculateExecuteProcess(){
        if (currentSecondTime < 0) {
            currentSecondTime = 0
        } else if (currentSecondTime > totalSecondTime) {
            currentSecondTime = totalSecondTime
        }
        executeProcess = ((currentSecondTime.toDouble() / (totalSecondTime).toDouble()) * 100).toInt()
    }
}
