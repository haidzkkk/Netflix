import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/data/api/api_client.dart';

class KkApiClient extends ApiClient{
  KkApiClient({required super.sharedPreferences})
      : super(apiBaseUrl: AppConstants.KK_BASE_URL);
}