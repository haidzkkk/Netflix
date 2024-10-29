import 'package:spotify/feature/data/api/kk_response/server_dto.dart';
import 'package:spotify/feature/data/models/movie_info.dart';

import 'movie_info_dto.dart';

class MovieDetailResponseDTO {
  bool? status;
  String? msg;
  MovieInfoDTO? movie;
  List<ServerDataDTO>? servers;

  MovieDetailResponseDTO({this.status, this.msg, this.movie, this.servers});

  MovieDetailResponseDTO.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    movie = json['movie'] != null ? MovieInfoDTO.fromJson(json['movie']) : null;
    if (json['episodes'] != null) {
      servers = <ServerDataDTO>[];
      json['episodes'].forEach((v) {
        servers!.add(ServerDataDTO.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['msg'] = msg;
    if (movie != null) {
      data['movie'] = movie!.toJson();
    }
    if (servers != null) {
      data['episodes'] = servers!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  MovieInfo? getMovieInfoData(){
    movie?.servers = servers;
    return movie?.toMovieInfo();
  }
}


