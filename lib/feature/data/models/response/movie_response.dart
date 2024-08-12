
import 'collection.dart';
import 'movie.dart';

class MovieResponse {
  bool? status;
  List<Movie>? items;
  Pagination? pagination;

  MovieResponse({this.status, this.items, this.pagination});

  MovieResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['items'] != null) {
      items = <Movie>[];
      json['items'].forEach((v) {
        items!.add(Movie.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}
