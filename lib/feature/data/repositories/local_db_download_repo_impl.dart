
import 'package:spotify/feature/data/models/entity/episode_download.dart';
import 'package:spotify/feature/data/models/entity/movie_local.dart';

abstract class LocalDbDownloadRepoImpl{

  Future<bool> addMovieToDownload(MovieLocal movie);

  Future<bool> addEpisodeToDownload(EpisodeDownload episode);

  Future<bool> deleteMovieAndEpisodeDownload(String movieId,);

  Future<bool> deleteEpisodeDownload(String id,);

  Future<List<MovieLocal>> getMovieDownload({String? movieId});

  Future<bool> checkMovieDownloading();

}