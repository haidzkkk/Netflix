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
import 'package:spotify/feature/blocs/download/download_cubit.dart';
import 'package:spotify/feature/blocs/main/main_bloc_cubit.dart';
import 'package:spotify/feature/blocs/movie/movie_bloc.dart';
import 'package:spotify/feature/blocs/setting/setting_cubit.dart';
import 'package:spotify/feature/blocs/watched/watched_cubit.dart';
import '../commons/utility/locale_util.dart';
import '../commons/utility/theme_ulti.dart';
import '../data/local/database_helper.dart';
import '../data/local/hive_manager.dart';
import '../data/repositories/auth_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/local_db_repository.dart';
import '../blocs/home/home_bloc.dart';
import '../blocs/search/search_bloc.dart';

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
  sl.registerLazySingleton(() => HomeBloc(movieRepoFactory: sl()));
  sl.registerLazySingleton(() => MainBloc(sharedPreferences: sl(), localeHelper: sl(), themeHelper: sl()));
  sl.registerLazySingleton(() => MovieBloc(movieRepoFactory: sl(), downloadRepo: sl<LocalDbRepository>(), historyRepo: sl<LocalDbRepository>()));
  sl.registerLazySingleton(() => SearchBloc(movieRepoFactory: sl()));
  sl.registerLazySingleton(() => WatchedCubit(localRepo: sl<LocalDbRepository>()));
  sl.registerLazySingleton(() => DownloadCubit(movieRepoFactory: sl(), dbRepository: sl<LocalDbRepository>(), fileRepository: sl<FileRepository>()));
  sl.registerLazySingleton(() => SettingCubit(repo: sl(), googleRepo: sl()));

  ///[Repository]
  sl.registerLazySingleton(() => AuthRepo(apiClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(() => MovieKkRepo(apiClient: sl()));
  sl.registerLazySingleton(() => MovieOpRepo(apiClient: sl()));
  sl.registerLazySingleton(() => LocalDbRepository(dataBaseHelper: sl()));
  sl.registerLazySingleton(() => FileRepository());
  sl.registerLazySingleton(() => SettingRepo(sharedPreferences: sl()));
  sl.registerLazySingleton(() => GoogleRepo(googleService: sl()));

  ///[Factory]
  sl.registerLazySingleton(() => MovieRepoFactory());
}
