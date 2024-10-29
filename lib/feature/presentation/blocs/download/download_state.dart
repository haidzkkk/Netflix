
import 'package:equatable/equatable.dart';
import 'package:spotify/feature/data/models/entity/episode_download.dart';
import 'package:spotify/feature/data/models/entity/movie_local.dart';
import 'package:spotify/feature/data/models/entity/movie_status_download.dart';

class DownloadState extends Equatable{

  final Map<String, MovieLocal> movies;
  final List<MovieStatusDownload> moviesDownloading;
  Map<String, EpisodeDownload> episodeDeleteSelect;

  DownloadState({
    Map<String, MovieLocal>? movies,
    List<MovieStatusDownload>? moviesDownloading,
    Map<String, EpisodeDownload>? episodeDeleteSelect,
  }): movies = movies ?? {},
      episodeDeleteSelect = episodeDeleteSelect ?? {},
      moviesDownloading = moviesDownloading ?? [];

  copyWith({
    Map<String, MovieLocal>? movies,
    Map<String, EpisodeDownload>? episodeDeleteSelect,
    List<MovieStatusDownload>? moviesDownloading,
  }){
    return DownloadState(
      movies: movies ?? this.movies,
      episodeDeleteSelect: episodeDeleteSelect ?? this.episodeDeleteSelect,
      moviesDownloading: moviesDownloading ?? this.moviesDownloading,
    );
  }

  @override
  List<Object?> get props => [movies.hashCode, episodeDeleteSelect, moviesDownloading];

}