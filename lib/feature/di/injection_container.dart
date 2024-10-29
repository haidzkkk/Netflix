import 'package:get_it/get_it.dart';
import 'package:spotify/context_service.dart';
import 'package:spotify/feature/data/api/kk_api_client.dart';
import 'package:spotify/feature/data/api/op_api_client.dart';
import 'package:spotify/feature/data/repositories/file_repo.dart';
import 'package:spotify/feature/commons/hepler/google_service.dart';
import 'package:spotify/feature/data/repositories/google_repo.dart';
import 'package:spotify/feature/data/repositories/movie_kk_repo.dart';
import 'package:spotify/feature/data/repositories/movie_op_repo.dart';
import 'package:spotify/feature/data/repositories/movie_repo_factory.dart';
import 'package:spotify/feature/data/repositories/setting_repo.dart';
import 'package:spotify/feature/presentation/blocs/download/download_cubit.dart';
import 'package:spotify/feature/presentation/blocs/main/main_bloc_cubit.dart';
import 'package:spotify/feature/presentation/blocs/movie/movie_bloc.dart';
import 'package:spotify/feature/presentation/blocs/setting/setting_cubit.dart';
import 'package:spotify/feature/presentation/blocs/watched/watched_cubit.dart';
import '../commons/utility/locale_util.dart';
import '../commons/utility/theme_ulti.dart';
import '../data/local/database_helper.dart';
import '../data/local/hive_manager.dart';
import '../data/repositories/auth_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/local_db_repository.dart';
import '../presentation/blocs/home/home_bloc.dart';
import '../presentation/blocs/search/search_bloc.dart';

///[NOTE] : input for [Global] data state
final sl = GetIt.instance;

Future<void> init() async {
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  /// [Flavor]
  /// [Implementation] flavor with different [Environm Env] both ios and android
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => OpApiClient(sharedPreferences: sl()));
  sl.registerLazySingleton(() => KkApiClient(sharedPreferences: sl()));
  sl.registerLazySingleton(() => LocaleHelper(sharedPreferences: sl()));
  sl.registerLazySingleton(() => ThemeHelper(sharedPreferences: sl()));
  sl.registerLazySingleton(() => HiveManager());
  sl.registerLazySingleton(() => DataBaseHelper.instance);
  sl.registerLazySingleton(() => ContextService());

  ///[Core]
  ///

  ///sentry client
  ///

  ///[External]
  ///
  sl.registerLazySingleton(() => GoogleService(sl<FileRepository>()));

  ///[Bloc]
  ///
  sl.registerFactory(() => HomeBloc(movieRepoFactory: sl()));
  sl.registerFactory(() => MainBloc(sharedPreferences: sl(), localeHelper: sl(), themeHelper: sl()));
  sl.registerFactory(() => MovieBloc(movieRepoFactory: sl(), downloadRepo: sl<LocalDbRepository>(), historyRepo: sl<LocalDbRepository>()));
  sl.registerFactory(() => SearchBloc(movieRepoFactory: sl()));
  sl.registerFactory(() => WatchedCubit(localRepo: sl<LocalDbRepository>()));
  sl.registerFactory(() => DownloadCubit(dbRepository: sl<LocalDbRepository>(), fileRepository: sl<FileRepository>()));
  sl.registerFactory(() => SettingCubit(repo: sl(), googleRepo: sl()));

  ///[Repository]
  sl.registerFactory(() => AuthRepo(apiClient: sl(), sharedPreferences: sl()));
  sl.registerFactory(() => MovieKkRepo(apiClient: sl()));
  sl.registerFactory(() => MovieOpRepo(apiClient: sl()));
  sl.registerFactory(() => LocalDbRepository(dataBaseHelper: sl()));
  sl.registerFactory(() => FileRepository());
  sl.registerFactory(() => SettingRepo(sharedPreferences: sl()));
  sl.registerFactory(() => GoogleRepo(googleService: sl()));

  ///[Factory]
  sl.registerLazySingleton(() => MovieRepoFactory());
}
