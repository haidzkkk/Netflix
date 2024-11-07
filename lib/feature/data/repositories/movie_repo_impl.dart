
import 'package:spotify/feature/data/api/kk_request/category_movie.dart';
import 'package:spotify/feature/data/models/data.dart';
import 'package:spotify/feature/data/models/movie_info.dart';

abstract class MovieRepoImpl{
  Future<Data<List<MovieInfo>>> getMovies({
    required CategoryMovie category,
    required int pageIndex
  });

  Future<Data<List<MovieInfo>>> searchMovie({
    required String keyword,
    int? limit
  });

  Future<Data<MovieInfo>> getInfoMovie<T>({
    required String slugMovie,
  });

}