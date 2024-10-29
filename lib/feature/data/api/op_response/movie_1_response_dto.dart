import 'package:spotify/feature/data/api/op_response/movie_info_dto.dart';
import 'package:spotify/feature/data/api/op_response/pagination_dto.dart';

class Movie1ResponseDTO {
  bool? status;
  List<MovieInfoDTO>? items;
  PaginationDTO? pagination;

  Movie1ResponseDTO({this.status, this.items, this.pagination});

  Movie1ResponseDTO.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['items'] != null) {
      items = <MovieInfoDTO>[];
      json['items'].forEach((v) {
        items!.add(MovieInfoDTO.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? PaginationDTO.fromJson(json['pagination'])
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
