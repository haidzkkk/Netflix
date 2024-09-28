
class AppConstants{
  static const String TOKEN = "sprf_token";
  static const String LANGUAGE_CODE = "sprf_language";
  static const String THEME_CODE = "sprf_theme";

  static const String BASE_URL = "https://phimapi.com";
  static const String BASE_URL_IMAGE = "https://phimimg.com";

  static const String GET_SEARCH = "/v1/api";
  static const String GET_LIST_MOVIE = "/danh-sach";
  static const String GET_CATEGORY_1 = "/v1/api/danh-sach";
  static const String GET_CATEGORY_2 = "/v1/api/the-loai";
  static const String GET_COUNTRY = "/v1/api/quoc-gia";
  static const String GET_DETAIL_MOVIE = "/phim";

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

  static const int defaultPageSize = 10;
}