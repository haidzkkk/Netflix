
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/api/kk_response/movie_2_response_dto.dart';
import 'package:spotify/feature/data/api/kk_response/movie_1_response_dto.dart';
import 'package:spotify/feature/data/api/server_type.dart';
import 'package:spotify/feature/data/models/data.dart';
import 'package:spotify/feature/data/models/movie_info.dart';
import 'package:spotify/gen/assets.gen.dart';

enum CategoryMovie{
  listCartoon(name: "Hoạt hình", slug: "hoat-hinh", path: AppConstants.KK_GET_CATEGORY_1, serverType: ServerType.kkPhim),
  search(name: "Tìm kiếm", slug: "tim-kiem", path: AppConstants.KK_GET_SEARCH, serverType: ServerType.kkPhim),
  movieNew(name: "Phim mới nhất", slug: "phim-moi-cap-nhat", path: AppConstants.KK_GET_LIST_MOVIE, serverType: ServerType.kkPhim),
  listMovieSingle(name: "Phim lẻ", slug: "phim-le", path: AppConstants.KK_GET_CATEGORY_1, serverType: ServerType.kkPhim),
  listTvShow(name: "Tv show", slug: "tv-shows", path: AppConstants.KK_GET_CATEGORY_1, serverType: ServerType.kkPhim),
  listSeries(name: "Phim bộ", slug: "phim-bo", path: AppConstants.KK_GET_CATEGORY_1, serverType: ServerType.kkPhim),
  listMovieAction(name: "Hành động", slug: "hanh-dong", path: AppConstants.KK_GET_CATEGORY_2, serverType: ServerType.kkPhim),
  listEmotional(name: "Tình cảm", slug: "tinh-cam", path: AppConstants.KK_GET_CATEGORY_2, serverType: ServerType.kkPhim),
  ;

  final String name;
  final String slug;
  final String path;
  final ServerType serverType;
  const CategoryMovie({required this.name, required this.slug, required this.path, required this.serverType});

  static CategoryMovie? getCategoryMovie(String? slug){
    return CategoryMovie.valueCategories.firstWhereOrNull((category){
      return category.slug == slug;
    });
  }

  static List<CategoryMovie> get valueCategories {
    return CategoryMovie.values.where((category) => category != CategoryMovie.search).toList();
  }

  static Map<String, CategoryMovie> get mapCategories {
    return Map.fromEntries(valueCategories.map((e) => MapEntry(e.slug, e)));
  }

  static List<String> toListString(List<CategoryMovie> data){
    return data.map((e) => e.slug).toList();
  }

  static List<CategoryMovie> fromListString(List<String> data){
    Map<String, CategoryMovie> mapCategoriesData = mapCategories;
    return data.map((e) => mapCategoriesData[e]).whereType<CategoryMovie>().toList();
  }

  /// decode data json movie each category
  Data<List<MovieInfo>> itemDataFromJson(Map<String, dynamic> body) {
    switch (path) {
      case AppConstants.KK_GET_LIST_MOVIE:{
        Movie1ResponseDTO res = Movie1ResponseDTO.fromJson(body);
        return Data<List<MovieInfo>>(
          data: res.items?.map((e) => e.toMovieInfo()).toList() ?? [],
          pageIndex: res.pagination?.currentPage,
          isLastPage: (res.pagination?.currentPage ?? 0) >= (res.pagination?.currentPage ?? 0)
        );
      }
      case AppConstants.KK_GET_CATEGORY_1 || AppConstants.KK_GET_CATEGORY_2 || AppConstants.KK_GET_SEARCH:{
        Movie2ResponseDTO res = Movie2ResponseDTO.fromJson(body[AppConstants.DATA]);
        return Data<List<MovieInfo>>(
            data: res.items?.map((e) => e.toMovieInfo()).toList() ?? [],
            pageIndex: res.params?.pagination?.currentPage,
            isLastPage: (res.params?.pagination?.currentPage ?? 0) >= (res.params?.pagination?.currentPage ?? 0)
        );
      }

      default:
        throw Exception("Unknown category path: $path");
    }
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "slug": slug,
    "path": path,
    "serverType": serverType,
  };
}

extension CategoryMovieExt on CategoryMovie{
  String get getPathImage {
    if(this == CategoryMovie.listCartoon){
      return Assets.img.cartoon.path;
    }else if(this == CategoryMovie.movieNew){
      return Assets.img.newMovie.path;
    }else if(this == CategoryMovie.listMovieSingle){
      return Assets.img.singleMovie.path;
    }else if(this == CategoryMovie.listTvShow){
      return Assets.img.tvshow.path;
    }else if(this == CategoryMovie.listSeries){
      return Assets.img.series.path;
    }else if(this == CategoryMovie.listMovieAction){
      return Assets.img.action.path;
    }else if(this == CategoryMovie.listEmotional){
      return Assets.img.emotional.path;
    }
    return "";
  }

}
