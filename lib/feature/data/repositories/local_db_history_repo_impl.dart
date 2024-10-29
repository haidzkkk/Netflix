
import 'package:spotify/feature/data/models/entity/episode_local.dart';
import 'package:spotify/feature/data/models/entity/movie_local.dart';

abstract class LocalDbHistoryRepoImpl {
  Future<bool> addMovieToHistory(MovieLocal movie);

  Future<List<MovieLocal>> getAllMovieHistory({
    required int pageIndex,
    int? pageSize,
  });

  Future<bool> deleteMovieHistory(int id,);

  Future<bool> addEpisodeToHistory(EpisodeLocal episode);

  Future<Map<String, EpisodeLocal>> getAllEpisodeFromMovieHistory(String movieId);
}