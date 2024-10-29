
import 'package:spotify/feature/data/api/server_type.dart';
import 'package:spotify/feature/data/repositories/movie_kk_repo.dart';
import 'package:spotify/feature/data/repositories/movie_op_repo.dart';
import 'package:spotify/feature/data/repositories/movie_repo_impl.dart';
import 'package:spotify/feature/di/injection_container.dart';

class MovieRepoFactory {
  MovieRepoImpl getMovieRepository(ServerType serverType){
    switch(serverType){
      case ServerType.kkPhim:
        return sl<MovieKkRepo>();
      case ServerType.oPhim:
        return sl<MovieOpRepo>();
      default:
        throw Exception("Invalid server type");
    }
  }
}