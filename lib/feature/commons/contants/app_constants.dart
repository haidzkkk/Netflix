
class AppConstants{
  static const String TOKEN = "sprf_token";
  static const String LANGUAGE_CODE = "sprf_language";
  static const String THEME_CODE = "sprf_theme";

  static const String KK_BASE_URL = "https://phimapi.com";
  static const String OP_BASE_URL = "https://ophim1.com";
  static const String KK_BASE_URL_IMAGE = "https://phimimg.com";
  static const String OP_BASE_URL_IMAGE = "https://img.ophim.live/uploads/movies";

  static const String KK_GET_SEARCH = "/v1/api";
  static const String KK_GET_LIST_MOVIE = "/danh-sach";
  static const String KK_GET_CATEGORY_1 = "/v1/api/danh-sach";
  static const String KK_GET_CATEGORY_2 = "/v1/api/the-loai";
  static const String KK_GET_COUNTRY = "/v1/api/quoc-gia";
  static const String KK_GET_DETAIL_MOVIE = "/phim";
  
  static const String OP_GET_DETAIL_MOVIE = "/phim";
  static const String OP_GET_SEARCH = "v1/api";

  static const int HTTP_OK = 200;

  static const String DATA = "data";
  static const String ITEMS = "items";
  static const String PAGINATION = "pagination";

  static const String dbName = "netflix.db.haidzkkk";
  static const int dbVersion = 1;

  static const String dbHive = "netflix.hive.haidzkkk";
  static const String movieHistoryBoxName = 'MovieHistoryBox';
  static const String searchBoxName = 'searchBox';

  static const String methodChanelDownload = 'com.example.method_chanel/download';
  static const String downloadStartDownload = 'startService';
  static const String downloadStopDownload = 'stopService';
  static const String methodEventDownload = 'com.example.method_event/download';
  static const String methodEventPip = 'com.example.method_event/pip';

  static const String methodChannelOpenMovie = "com.example.method_chanel/openMovie";
  static const String methodChannelWidgetProvider = "com.example.method_chanel/widgetProvider";
  static const String openMovieInvokeMethod = "openMovie";
  static const String invokeMethodProvideMovie = "provideMovie";
  static const String invokeMethodDragWidget = "dragWidget";
  static const String provideMovieData = "data";
  static const String provideMovieCategory = "category";

  static const String backupFolderName = "NetFLixBackup";
  static const String backupMineType = "application/vnd.google-apps.folder";

  static const String appShare = 'https://github.com/haidzkkk/netflix';

  static const int defaultPageSize = 10;

  static const String spfsWatchBackground = 'spfs1#_watchBackground';
  static const String spfsAutoChangeEpisode = 'spfs1#_autoChangeEpisode';
  static const String spfsSuggestEpisodeWatched = 'spfs1#_suggestEpisodeWatched';
  static const String spfsFavouriteCategories = 'spfs1#_favouriteCategories';
  static const String spfsShowNotifyWhenDownloadSuccess = 'spfs1#_showNotifyWhenDownloadSuccess';

}