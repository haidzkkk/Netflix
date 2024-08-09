
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';

extension LocaleUtil on BuildContext{
  AppLocalizations get locale {
    AppLocalizations? appLocalizations = AppLocalizations.of(this);
    if(appLocalizations == null) throw Exception("Locale is request before Localization initalized");

    return appLocalizations;
  }
}

class LocaleHelper{
  final SharedPreferences sharedPreferences;

  LocaleHelper({required this.sharedPreferences});

  Future<Locale> setLocaleLocal(String languageCode) async{
    await sharedPreferences.setString(AppConstants.LANGUAGE_CODE, languageCode);
    return Locale(languageCode);
  }

  Locale? getLocaleLocal(){
    String? languageCode = sharedPreferences.getString(AppConstants.LANGUAGE_CODE);
    if(languageCode != null) return Locale(languageCode);
    return null;
  }

  static List<Locale> getLocales(){
    return AppLocalizations.supportedLocales;
  }
}