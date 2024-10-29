
import 'package:spotify/feature/data/models/entity/episode_download.dart';
import 'package:spotify/feature/data/models/episode.dart';

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