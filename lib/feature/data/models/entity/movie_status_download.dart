import 'package:spotify/feature/data/api/server_type.dart';
import 'package:spotify/feature/data/models/entity/episode_download.dart';
import 'package:spotify/feature/data/models/episode.dart';
import 'package:spotify/feature/data/models/movie_info.dart';

class MovieStatusDownload {
  String? id;
  String? movieId;
  String? movieName;
  String? movieSlug;
  String? name;
  String? slug;
  StatusDownload? status;
  String? localPath;
  String? url;
  int? totalSecondTime;
  int? currentSecondTime;
  int? executeProcess;

  ServerType? serverType;

  MovieStatusDownload(
      {this.currentSecondTime,
        this.executeProcess,
        this.localPath,
        this.name,
        this.movieId,
        this.movieName,
        this.movieSlug,
        this.slug,
        this.status,
        this.totalSecondTime,
        this.url,
        required this.serverType,
      }){
    id = EpisodeDownload.getSetupId(movieId: movieId ?? "", slug: slug ?? "");
  }

  factory MovieStatusDownload.fromMovieEpisode({
    required MovieInfo movie,
    required Episode episode,
    required String localPath,
}) {
    return MovieStatusDownload(
        slug: episode.slug,
        name: episode.name,
        movieId: movie.sId,
        movieName: "${movie.name} - ${episode.name}",
        movieSlug: movie.slug,
        // url: "https://flipfit-cdn.akamaized.net/flip_hls/661f570aab9d840019942b80-473e0b/video_h1.m3u8",
        url: episode.linkM3u8,
        localPath: localPath,
        serverType: movie.serverType
    );
  }

  MovieStatusDownload.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currentSecondTime = json['currentSecondTime'];
    executeProcess = json['executeProcess'];
    localPath = json['localPath'];
    name = json['name'];
    movieId = json['movieId'];
    movieName = json['movieName'];
    movieSlug = json['movieSlug'];
    slug = json['slug'];
    status = json['status'] != null ? StatusDownload.fromJson(json['status']) : null;
    totalSecondTime = json['totalSecondTime'];
    url = json['url'];
    serverType = ServerType.getServerType(json['serverType']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currentSecondTime'] = currentSecondTime;
    data['executeProcess'] = executeProcess;
    data['localPath'] = localPath;
    data['name'] = name;
    data['movieId'] = movieId;
    data['movieName'] = movieName;
    data['movieSlug'] = movieSlug;
    data['slug'] = slug;
    data['id'] = id;
    if (status != null) {
      data['status'] = status!.toJson();
    }
    data['totalSecondTime'] = totalSecondTime;
    data['url'] = url;
    data['serverType'] = serverType?.id;
    return data;
  }
}

class StatusDownload {
  static const String INITIALIZATION = "INITIALIZATION";
  static const String SUCCESS = "SUCCESS";
  static const String ERROR = "ERROR";
  static const String LOADING = "LOADING";
  static const String CANCEL = "CANCEL";

  String? data;
  String? status;

  StatusDownload({this.data, this.status});

  StatusDownload.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data;
    data['status'] = status;
    return data;
  }
}
