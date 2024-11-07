import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/data/api/kk_api_client.dart';
import 'package:spotify/feature/data/api/kk_request/category_movie.dart';
import 'package:spotify/feature/data/api/kk_response/movie_detail_response_dto.dart';
import 'package:spotify/feature/data/models/data.dart';
import 'package:spotify/feature/data/models/movie_info.dart';
import 'package:spotify/feature/data/repositories/movie_repo_impl.dart';

class MovieKkRepo implements MovieRepoImpl {
  KkApiClient apiClient;

  MovieKkRepo({required this.apiClient});

  @override
  Future<Data<MovieInfo>> getInfoMovie<T>({
    required String slugMovie
  }) async {
      var response = await apiClient.getData(
        uri: '${AppConstants.KK_GET_DETAIL_MOVIE}/$slugMovie' ,
      );

      Data<MovieInfo> data = Data(
        statusCode: response.statusCode,
        msg: response.statusText,
      );

      if(data.statusCode == AppConstants.HTTP_OK && response.body[AppConstants.HTTP_STATUS] == true){
        MovieDetailResponseDTO movieResponse = MovieDetailResponseDTO.fromJson(response.body);
        data.data = movieResponse.getMovieInfoData();
      }

      return data;
  }

  @override
  Future<Data<List<MovieInfo>>> getMovies({
    required CategoryMovie category,
    required int pageIndex
  }) async {
      var query = {
        "page": "$pageIndex",
      };

      var response = await apiClient.getData(
        uri: "${category.path}/${category.slug}",
        query: query,
      );

      Data<List<MovieInfo>> data = Data(
        statusCode: response.statusCode,
        msg: response.statusText,
      );

       if(data.statusCode == AppConstants.HTTP_OK){
         data.data = category.itemDataFromJson(response.body).data;
      }

       return data;
  }

  @override
  Future<Data<List<MovieInfo>>> searchMovie({
    required String keyword,
    int? limit
  }) async{
    CategoryMovie category = CategoryMovie.kkSearch;
    var query = {
      "keyword": keyword,
      "limit": "${limit ?? 100}",
    };
    var response = await apiClient.getData(
      uri: "${category.path}/${category.slug}",
      query: query,
    );

    Data<List<MovieInfo>> data = Data(
      statusCode: response.statusCode,
      msg: response.statusText,
    );

    if(data.statusCode == AppConstants.HTTP_OK){
      data.data = category.itemDataFromJson(response.body).data;
    }

    return data;
  }

}