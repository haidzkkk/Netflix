import 'package:spotify/feature/data/models/db_local/episode_download.dart';
import 'package:spotify/feature/data/models/db_local/episode_local.dart';

import 'movie_info.dart';

class MovieInfoResponse {
  bool? status;
  String? msg;
  MovieInfo? movie;
  List<ServerData>? episodes;

  MovieInfoResponse({this.status, this.msg, this.movie, this.episodes});

  MovieInfoResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    movie = json['movie'] != null ? MovieInfo.fromJson(json['movie']) : null;
    if (json['episodes'] != null) {
      episodes = <ServerData>[];
      json['episodes'].forEach((v) {
        episodes!.add(ServerData.fromJson(v));
      });
    }
    movie?.episodes = episodes;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['msg'] = msg;
    if (movie != null) {
      data['movie'] = movie!.toJson();
    }
    if (episodes != null) {
      data['episodes'] = episodes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServerData {
  static const String SERVER_NAME_LOCAL = "local";

  String? serverName;
  List<Episode>? episode;

  ServerData({this.serverName, this.episode});

  ServerData.fromJson(Map<String, dynamic> json) {
    serverName = json['server_name'];
    if (json['server_data'] != null) {
      episode = <Episode>[];
      json['server_data'].forEach((v) {
        episode!.add(Episode.fromJson(v));
      });
    }
  }

  ServerData.fromEpisodeLocal(Map<String, EpisodeDownload>? episodesDownload) {
    serverName = SERVER_NAME_LOCAL;
    episode = episodesDownload?.values.toList().map((episodeDownload){
      return episodeDownload.toEpisode()..episodesDownload = episodeDownload;
    }).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['server_name'] = serverName;
    if (episode != null) {
      data['server_data'] = episode!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Episode {
  String? name;
  String? slug;
  String? filename;
  String? linkEmbed;
  String? linkM3u8;

  EpisodeLocal? episodeLocal;
  EpisodeDownload? episodesDownload;

  Episode(
      {this.name, this.slug, this.filename, this.linkEmbed, this.linkM3u8, this.episodeLocal});

  Episode.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    slug = json['slug'];
    filename = json['filename'];
    linkEmbed = json['link_embed'];
    linkM3u8 = json['link_m3u8'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['slug'] = slug;
    data['filename'] = filename;
    data['link_embed'] = linkEmbed;
    data['link_m3u8'] = linkM3u8;
    return data;
  }
}
