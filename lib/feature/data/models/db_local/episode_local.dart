
import '../movie_detail/movie_info_response.dart';

class EpisodeLocalField{

  static const String tableName = 'episode';

  static const String id = 'id';
  static const String movieId = 'movieId';
  static const String slug = 'slug';
  static const String name = 'name';
  static const String currentSecond = 'currentSecond';
  static const String lastTime = 'lastTime';

  static final List<String> query = [tableName, id, movieId, slug, name, currentSecond,];
}

class EpisodeLocal{
  String? _id;
  String? movieId;
  String? slug;
  String? name;
  int? currentSecond;
  int? lastTime;

  EpisodeLocal({
    String? id,
    this.movieId,
    this.slug,
    this.name,
    this.currentSecond,
    this.lastTime,
  }){
    _id = id ?? getSetupId();
  }

  String getSetupId(){
    return "${movieId}_$slug";
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'movieId': movieId,
      'slug': slug,
      'name': name,
      'currentSecond': currentSecond,
      'lastTime': lastTime,
    };
  }

  factory EpisodeLocal.fromJson(Map<String, dynamic> json) {
    return EpisodeLocal(
      id: json['id'],
      movieId: json['movieId'],
      slug: json['slug'],
      name: json['name'],
      currentSecond: json['currentSecond'],
      lastTime: json['lastTime'],
    );
  }

  factory EpisodeLocal.fromWhenWatched({
    required String movieID,
    required Episode body,
    required int currentSecond,
    required int lastTime,
  }) {
    return EpisodeLocal(
      movieId: movieID,
      slug: body.slug,
      name: body.name,
      currentSecond: currentSecond,
      lastTime: lastTime,
    );
  }
}