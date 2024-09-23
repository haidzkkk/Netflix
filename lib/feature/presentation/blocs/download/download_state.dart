
import 'package:equatable/equatable.dart';
import 'package:spotify/feature/data/models/db_local/movie_local.dart';
import 'package:spotify/feature/data/models/db_local/movie_status_download.dart';

class DownloadState extends Equatable{

  final Map<String, MovieLocal> movies;
  final List<MovieStatusDownload> moviesDownloading;

  DownloadState({
    Map<String, MovieLocal>? movies,
    List<MovieStatusDownload>? moviesDownloading,
  }): movies = movies ?? {},
      moviesDownloading = moviesDownloading ?? [];

  copyWith({
    Map<String, MovieLocal>? movies,
    List<MovieStatusDownload>? moviesDownloading,
  }){
    return DownloadState(
      movies: movies ?? this.movies,
      moviesDownloading: moviesDownloading ?? this.moviesDownloading,
    );
  }

  @override
  List<Object?> get props => [movies.hashCode, moviesDownloading];

}