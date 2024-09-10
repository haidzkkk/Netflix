package com.example.spotify.data.model
import java.io.Serializable

class Status<out T> (val status: StatusEnum, val data: T?, val message: String?): Serializable {

    companion object{
        fun <T> Initialization(): Status<T> = Status<T>(StatusEnum.INITIALIZATION, null, null)

        fun <T> Loading(data: T?): Status<T> = Status<T>(StatusEnum.LOADING, data, null)

        fun <T> Success(data: T?): Status<T> = Status<T>(StatusEnum.SUCCESS, data, null)

        fun <T> Error(data: T?, message: String?): Status<T> = Status<T>(StatusEnum.ERROR, data, message)
    }
}

enum class StatusEnum: Serializable {
    INITIALIZATION,
    SUCCESS,
    ERROR,
    LOADING
}
