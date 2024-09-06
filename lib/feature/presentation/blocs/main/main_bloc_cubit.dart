import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../commons/utility/locale_util.dart';
import '../../../commons/utility/theme_ulti.dart';

part 'main_bloc_state.dart';

class MainBloc extends Cubit<MainState> {
  final SharedPreferences sharedPreferences;
  final LocaleHelper localeHelper;
  final ThemeHelper themeHelper;

  MainBloc({
    required this.sharedPreferences,
    required this.localeHelper,
    required this.themeHelper,
  }) : super(MainState());

  initMain(){
    getLocalLocale();
    getLocalTheme();
  }

  getLocalLocale(){
    var locale = localeHelper.getLocaleLocal();
    emit(state.copyWithLocale(locale));
  }

  changeLocale(String languageCode) async{
    Locale locale = await localeHelper.setLocaleLocal(languageCode);
    emit(state.copyWithLocale(locale));
  }

  getLocalTheme(){
    var darkMode = themeHelper.getLocaleLocal();
    emit(state.copyWithDarkMode(darkMode ?? false));
  }

  changeTheme(bool darkMode) async{
    await themeHelper.setThemeLocal(darkMode);
    emit(state.copyWithDarkMode(darkMode));
  }
}
