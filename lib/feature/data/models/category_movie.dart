
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/models/response/collection.dart';
import 'package:spotify/feature/data/models/response/movie.dart';
import 'package:spotify/feature/data/models/response/movie_response.dart';

import '../../commons/contants/app_constants.dart';
import 'data.dart';

enum CategoryMovie{
  search(name: "Tìm kiếm", slug: "tim-kiem", path: AppConstants.GET_SEARCH),
  movieNew(name: "Phim mới cập nhật", slug: "phim-moi-cap-nhat", path: AppConstants.GET_LIST_MOVIE),
  listMovieSingle(name: "Phim lẻ", slug: "phim-le", path: AppConstants.GET_CATEGORY_1),
  listCartoon(name: "Hoạt hình", slug: "hoat-hinh", path: AppConstants.GET_CATEGORY_1),
  listTvShow(name: "Tv show", slug: "tv-shows", path: AppConstants.GET_CATEGORY_1),
  listMovieAction(name: "Hành động", slug: "hanh-dong", path: AppConstants.GET_CATEGORY_2),
  listEmotional(name: "Tình cảm", slug: "tinh-cam", path: AppConstants.GET_CATEGORY_2),
  ;

  final String name;
  final String slug;
  final String path;
  const CategoryMovie({required this.name, required this.slug, required this.path});

  static CategoryMovie? getCategoryMovie(String? slug){
    return CategoryMovie.valuesCategory.firstWhereOrNull((category){
      return category.slug == slug;
    });
  }

  static List<CategoryMovie> get valuesCategory {
    return CategoryMovie.values.where((category) => category != CategoryMovie.search).toList();
  }

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
