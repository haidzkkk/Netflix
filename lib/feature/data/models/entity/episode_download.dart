import 'package:equatable/equatable.dart';
import 'package:spotify/feature/data/models/entity/movie_status_download.dart';
import 'package:spotify/feature/data/models/episode.dart';

class EpisodeDownloadField{

  static const String tableName = 'episodeDownload';

  static const String id = 'id';
  static const String movieId = 'movieId';
  static const String slug = 'slug';
  static const String name = 'name';
  static const String path = 'path';
  static const String status = 'status';
  static const String totalSecondTime = 'totalSecondTime';

  static final List<String> query = [tableName, id, movieId, slug, name, status, totalSecondTime,];
}

class EpisodeDownload extends Equatable{
  String? _id;
  String? movieId;
  String? slug;
  String? name;
  String? path;
  String? status;
  int? totalSecondTime;

  int? executeProcess;

  EpisodeDownload({
    String? id,
    this.movieId,
    this.slug,
    this.name,
    this.path,
    this.status,
    this.totalSecondTime,
  }){
    _id = id ?? getSetupId(movieId: movieId ?? "", slug: slug ?? "");
  }

  String? get id => _id;

  static String getSetupId({required String movieId, required String slug}){
    return "${movieId}_$slug";
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'movieId': movieId,
      'slug': slug,
      'name': name,
      'path': path,
      'status': status,
      'totalSecondTime': totalSecondTime,
    };
  }

  Episode toEpisode() {
    return Episode(
      slug: slug,
      name: name,
      filename: path,
    );
  }

  factory EpisodeDownload.fromJson(Map<String, dynamic> json) {
    return EpisodeDownload(
      id: json['id'],
      movieId: json['movieId'],
      slug: json['slug'],
      name: json['name'],
      path: json['path'],
      status: json['status'],
      totalSecondTime: json['totalSecondTime'],
    );
  }

  factory EpisodeDownload.fromWhenDownload(MovieStatusDownload data) {
    return EpisodeDownload(
      movieId: data.movieId,
      slug: data.slug,
      name: data.name,
      path: data.localPath,
      status: data.status?.status,
      totalSecondTime: data.totalSecondTime,
    )..executeProcess = data.executeProcess;
  }

  @override
  List<Object?> get props => [
  _id,
  movieId,
  slug,
  name,
  path,
  status,
  totalSecondTime,
  executeProcess,
  ];
}