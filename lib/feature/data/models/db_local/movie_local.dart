
import 'package:spotify/feature/data/models/db_local/episode_download.dart';
import 'package:spotify/feature/data/models/db_local/movie_status_download.dart';

import '../movie_detail/movie_info.dart';
import 'episode_local.dart';

class MovieLocalField{
  static const String movieTableName = 'movie';
  static const String movieDownloadTableName = 'movieDownload';

  static const String id = 'id';
  static const String movieId = 'movieId';
  static const String movieSlug = 'slug';
  static const String movieName = 'name';
  static const String moviePoster = 'poster';
  static const String movieThumb = 'thumb';
  static const String movieLastTime = 'lastTime';

  static final List<String> query = [id, movieId, movieSlug, movieName, moviePoster, movieThumb, movieLastTime,];
}

class MovieLocal{
  dynamic id;
  String? movieId;
  String? slug;
  String? name;
  String? poster;
  String? thumb;
  int? lastTime;

  List<EpisodeLocal>? episodes;
  Map<String, EpisodeDownload>? episodesDownload;

  MovieLocal({
    this.id,
    this.movieId,
    this.slug,
    this.name,
    this.poster,
    this.thumb,
    this.lastTime,
    this.episodes,
    this.episodesDownload,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieId': movieId,
      'slug': slug,
      'name': name,
      'poster': poster,
      'thumb': thumb,
      'lastTime': lastTime,
    };
  }

  Map<String, dynamic> toJsonDownload() {
    return {
      'movieId': movieId,
      'slug': slug,
      'name': name,
      'poster': poster,
      'thumb': thumb,
      'lastTime': lastTime,
    };
  }

  MovieInfo toMovieInfo() {
    return MovieInfo(
      sId: movieId,
      slug: slug,
      name: name,
      posterUrl: poster,
      thumbUrl: thumb,
    );
  }

  factory MovieLocal.fromJson(Map<String, dynamic> json) {
    return MovieLocal(
      id: json['id'],
      movieId: json['movieId'],
      slug: json['slug'],
      name: json['name'],
      poster: json['poster'],
      thumb: json['thumb'],
      lastTime: json['lastTime'],
      episodes: json['episodes'] != null ? (json['episodes'] as List).map((e) => EpisodeLocal.fromJson(e)).toList() : null,
      episodesDownload: json['episodesDownload'] != null ? Map.fromEntries((json['episodesDownload'] as List).map((e) {
        var item = EpisodeDownload.fromJson(e);
        return MapEntry(item.id ?? "", item);
      })) : null,
    );
  }

  factory MovieLocal.fromMovieInfo(MovieInfo body) {
    return MovieLocal(
      movieId: body.sId,
      slug: body.slug,
      name: body.name,
      poster: body.posterUrl,
      thumb: body.thumbUrl,
      lastTime: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory MovieLocal.fromMovieStatusDownload(MovieStatusDownload body) {
    return MovieLocal(
      movieId: body.movieId,
      slug: body.movieSlug,
      name: body.movieName,
      poster: "body.posterUrl",
      thumb: "body.thumbUrl",
      lastTime: DateTime.now().millisecondsSinceEpoch,
    );
  }
}