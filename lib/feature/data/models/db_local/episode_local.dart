
import '../movie_detail/movie_info_response.dart';

class EpisodeLocalField{

  static const String episodeTableName = 'episode';

  static const String episodeId = 'id';
  static const String movieId = 'movieId';
  static const String episodeSlug = 'slug';
  static const String episodeName = 'name';
  static const String episodeCurrentSecond = 'currentSecond';

  static final List<String> query = [episodeTableName, episodeId, movieId, episodeSlug, episodeName, episodeCurrentSecond,];
}

class EpisodeLocal{
  int? id;
  String? movieId;
  String? slug;
  String? name;
  int? currentSecond;

  EpisodeLocal({
    this.id,
    this.movieId,
    this.slug,
    this.name,
    this.currentSecond,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieId': movieId,
      'slug': slug,
      'name': name,
      'currentSecond': currentSecond,
    };
  }

  factory EpisodeLocal.fromJson(Map<String, dynamic> json) {
    return EpisodeLocal(
      id: json['id'],
      movieId: json['movieId'],
      slug: json['slug'],
      name: json['name'],
      currentSecond: json['currentSecond'],
    );
  }

  factory EpisodeLocal.fromEpisode({required String movieID, required Episode body, required int currentSecond}) {
    return EpisodeLocal(
      movieId: movieID,
      slug: body.slug,
      name: body.name,
      currentSecond: currentSecond,
    );
  }
}