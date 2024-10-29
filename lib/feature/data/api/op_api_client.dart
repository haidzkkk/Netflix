import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/data/api/api_client.dart';

class OpApiClient extends ApiClient{
  OpApiClient({required super.sharedPreferences})
      : super(apiBaseUrl: AppConstants.OP_BASE_URL);
}