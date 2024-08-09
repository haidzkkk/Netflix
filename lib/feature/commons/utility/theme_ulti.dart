
import 'package:shared_preferences/shared_preferences.dart';

import '../contants/app_constants.dart';

class ThemeHelper{
  final SharedPreferences sharedPreferences;

  ThemeHelper({required this.sharedPreferences});

  Future<bool> setThemeLocal(bool isDarkMode) async{
    await sharedPreferences.setBool(AppConstants.THEME_CODE, isDarkMode);
    return isDarkMode;
  }

  bool? getLocaleLocal(){
    return sharedPreferences.getBool(AppConstants.THEME_CODE);
  }

}