
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/models/response/collection.dart';
import 'package:spotify/feature/data/models/response/movie.dart';
import 'package:spotify/feature/data/models/response/movie_response.dart';
import 'package:spotify/gen/assets.gen.dart';

import '../../commons/contants/app_constants.dart';
import 'data.dart';

enum CategoryMovie{
  listCartoon(name: "Hoạt hình", slug: "hoat-hinh", path: AppConstants.GET_CATEGORY_1),
  search(name: "Tìm kiếm", slug: "tim-kiem", path: AppConstants.GET_SEARCH),
  movieNew(name: "Phim mới nhất", slug: "phim-moi-cap-nhat", path: AppConstants.GET_LIST_MOVIE),
  listMovieSingle(name: "Phim lẻ", slug: "phim-le", path: AppConstants.GET_CATEGORY_1),
  listTvShow(name: "Tv show", slug: "tv-shows", path: AppConstants.GET_CATEGORY_1),
  listSeries(name: "Phim bộ", slug: "phim-bo", path: AppConstants.GET_CATEGORY_1),
  listMovieAction(name: "Hành động", slug: "hanh-dong", path: AppConstants.GET_CATEGORY_2),
  listEmotional(name: "Tình cảm", slug: "tinh-cam", path: AppConstants.GET_CATEGORY_2),
  ;

  final String name;
  final String slug;
  final String path;
  const CategoryMovie({required this.name, required this.slug, required this.path});

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
  Data<List<Movie>> itemDataFromJson(Map<String, dynamic> body) {
    switch (path) {
      case AppConstants.GET_LIST_MOVIE:{
        MovieResponse res = MovieResponse.fromJson(body);
        return Data<List<Movie>>(
          data: res.items ?? [],
          pageIndex: res.pagination?.currentPage,
          isLastPage: (res.pagination?.currentPage ?? 0) >= (res.pagination?.currentPage ?? 0)
        );
      }
      case AppConstants.GET_CATEGORY_1 || AppConstants.GET_CATEGORY_2 || AppConstants.GET_SEARCH:{
        Collection res = Collection.fromJson(body[AppConstants.DATA]);
        return Data<List<Movie>>(
            data: res.items,
            pageIndex: res.params?.pagination?.currentPage,
            isLastPage: (res.params?.pagination?.currentPage ?? 0) >= (res.params?.pagination?.currentPage ?? 0)
        );
      }

      default:
        throw Exception("Unknown category path: $path");
    }
  }
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
