import 'package:get_it/get_it.dart';
import 'package:spotify/feature/data/repositories/movie_repo.dart';
import 'package:spotify/feature/presentation/blocs/main/main_bloc_cubit.dart';
import 'package:spotify/feature/presentation/blocs/movie/movie_bloc.dart';
import 'package:spotify/feature/presentation/blocs/watched/watched_cubit.dart';
import '../commons/utility/locale_util.dart';
import '../commons/utility/theme_ulti.dart';
import '../data/api/api_client.dart';
import '../data/local/database_helper.dart';
import '../data/local/hive_manager.dart';
import '../data/repositories/auth_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/local_db_repository.dart';
import '../data/repositories/local_nosql_repository.dart';
import '../presentation/blocs/home/home_bloc.dart';
import '../presentation/blocs/search/search_bloc.dart';

///[NOTE] : input for [Global] data state
final sl = GetIt.instance;

Future<void> init() async {
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  /// [Flavor]
  /// [Implementation] flavor with different [Environm Env] both ios and android
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => ApiClient(sharedPreferences: sl()));
  sl.registerLazySingleton(() => LocaleHelper(sharedPreferences: sl()));
  sl.registerLazySingleton(() => ThemeHelper(sharedPreferences: sl()));
  sl.registerLazySingleton(() => HiveManager());
  sl.registerLazySingleton(() => DataBaseHelper.instance);

  ///[Core]
  ///

  ///sentry client
  ///

  ///[External]
  ///

  ///[Bloc]
  ///
  sl.registerFactory(() => HomeBloc(repo: sl()));
  sl.registerFactory(() => MainBloc(sharedPreferences: sl(), localeHelper: sl(), themeHelper: sl()));
  sl.registerFactory(() => MovieBloc(sl(), sl()));
  sl.registerFactory(() => SearchBloc(repo: sl()));
  sl.registerFactory(() => WatchedCubit(localRepo: sl()));

  ///[Repository]
  sl.registerFactory(() => AuthRepo(apiClient: sl(), sharedPreferences: sl()));
  sl.registerFactory(() => MovieRepo(sl(), sl()));
  sl.registerFactory(() => LocalDbRepository(sl()));
  sl.registerFactory(() => LocalNosqlRepository(sl()));
}
