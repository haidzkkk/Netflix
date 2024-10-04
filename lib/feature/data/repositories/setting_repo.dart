
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/data/models/category_movie.dart';

enum SettingBoolEnum{
  watchBackground(AppConstants.spfsWatchBackground),
  autoChangeEpisode(AppConstants.spfsAutoChangeEpisode),
  suggestEpisodeWatched(AppConstants.spfsSuggestEpisodeWatched),
  showNotifyWhenDownloadSuccess(AppConstants.spfsShowNotifyWhenDownloadSuccess)
  ;

  const SettingBoolEnum(this.key);
  final String key;
}

class SettingRepo {
  SharedPreferences sharedPreferences;
  SettingRepo(this.sharedPreferences);

  Future<bool> setBoolData(SettingBoolEnum type, bool data) async{
    return await sharedPreferences.setBool(type.key, data);
  }

  bool? getBoolData(SettingBoolEnum type){
    return sharedPreferences.getBool(type.key);
  }

  Future<bool> setListFavouriteCategory(List<CategoryMovie> data) async{
    return await sharedPreferences.setStringList(
      AppConstants.spfsFavouriteCategories,
      CategoryMovie.toListString(data)
    );
  }

  List<CategoryMovie> getListFavouriteCategory(){
    return CategoryMovie.fromListString(
        sharedPreferences.getStringList(AppConstants.spfsFavouriteCategories) ?? []
    );
  }

}