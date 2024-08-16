import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/data/api/api_client.dart';
import 'package:spotify/feature/data/models/response.dart';

import '../models/category_movie.dart';

class MovieRepo {
  ApiClient apiClient;
  SharedPreferences sharedPreferences;

  MovieRepo(this.apiClient, this.sharedPreferences);

  Future<Response> getMovieCategory({
    required CategoryMovie category,
    required int pageIndex
  }) async{
    var query = {
      "page": "$pageIndex",
    };
    return await apiClient.getData(
      uri: "${category.path}/${category.slug}",
      query: query,
    );
  }

  Future<Response> searchMovie({
    required String keyword,
    int? limit
  }) async{
    CategoryMovie category = CategoryMovie.search;
    var query = {
      "keyword": keyword,
      "limit": "${limit ?? 100}",
    };
    return await apiClient.getData(
      uri: "${category.path}/${category.slug}",
      query: query,
    );
  }

  Future<Response> getInfoMovie({
    required String slugMovie,
  }) async{
    return await apiClient.getData(
      uri: '${AppConstants.GET_DETAIL_MOVIE}/$slugMovie' ,
    );
  }

}