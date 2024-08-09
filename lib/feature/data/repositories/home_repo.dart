
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/feature/data/api/api_client.dart';
import 'package:spotify/feature/data/models/response.dart';

import '../../commons/contants/app_constants.dart';

class HomeRepo {
  ApiClient apiClient;
  SharedPreferences sharedPreferences;

  HomeRepo(this.apiClient, this.sharedPreferences);

  Future<Response> getListMovie(int pageIndex) async{
    var query = {
      "page": "$pageIndex",
    };
    return await apiClient.getData(uri: AppConstants.LIST_MOVIE, query: query,);
  }
}