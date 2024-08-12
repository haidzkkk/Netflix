
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/feature/data/api/api_client.dart';
import 'package:spotify/feature/data/models/response.dart';
import 'package:spotify/feature/presentation/blocs/home/home_state.dart';

import '../../commons/contants/app_constants.dart';

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
    return await apiClient.getData(uri: "${category.path}/${category.slug}", query: query,);
  }
}