
import 'package:equatable/equatable.dart';
import 'package:spotify/feature/data/models/category_movie.dart';
import 'package:spotify/feature/data/models/db_local/movie_local.dart';

class SettingState extends Equatable{
  final bool isWatchBackground;
  final bool isAutoChangeEpisode;
  final bool isSuggestEpisodeWatched;
  final List<CategoryMovie> favouriteCategories;
  final bool isShowNotifyWhenDownloadSuccess;

  SettingState({
    bool? isWatchBackground,
    bool? isAutoChangeEpisode,
    bool? isSuggestEpisodeWatched,
    List<CategoryMovie>? favouriteCategories,
    bool? isShowNotifyWhenDownloadSuccess,
  }):
        isWatchBackground = isWatchBackground ?? true,
        isAutoChangeEpisode = isAutoChangeEpisode ?? true,
        isSuggestEpisodeWatched = isSuggestEpisodeWatched ?? true,
        favouriteCategories = favouriteCategories ?? CategoryMovie.valueCategories,
        isShowNotifyWhenDownloadSuccess = isShowNotifyWhenDownloadSuccess ?? true;

  SettingState copyWith({
    bool? isWatchBackground,
    bool? isAutoChangeEpisode,
    bool? isSuggestEpisodeWatched,
    List<CategoryMovie>? favouriteCategories,
    bool? isShowNotifyWhenDownloadSuccess,
  }){
    return SettingState(
      isWatchBackground: isWatchBackground ?? this.isWatchBackground,
      isAutoChangeEpisode: isAutoChangeEpisode ?? this.isAutoChangeEpisode,
      isSuggestEpisodeWatched: isSuggestEpisodeWatched ?? this.isSuggestEpisodeWatched,
      favouriteCategories: favouriteCategories?.isNotEmpty == true ? favouriteCategories : this.favouriteCategories,
      isShowNotifyWhenDownloadSuccess: isShowNotifyWhenDownloadSuccess ?? this.isShowNotifyWhenDownloadSuccess,
    );
  }

  @override
  List<Object?> get props => [
    isWatchBackground,
    isAutoChangeEpisode,
    isSuggestEpisodeWatched,
    favouriteCategories.hashCode,
    isShowNotifyWhenDownloadSuccess
  ];

}