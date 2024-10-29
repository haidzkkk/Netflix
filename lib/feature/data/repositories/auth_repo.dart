import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/feature/data/api/kk_api_client.dart';

import '../api/api_client.dart';

class AuthRepo{
  final KkApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AuthRepo({required this.apiClient, required this.sharedPreferences});

}