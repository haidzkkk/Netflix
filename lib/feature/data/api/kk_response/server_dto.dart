
import 'package:spotify/feature/data/api/kk_response/episode_dto.dart';
import 'package:spotify/feature/data/models/server_data.dart';

class ServerDataDTO {

  String? serverName;
  List<EpisodeDTO>? episode;

  ServerDataDTO({this.serverName, this.episode});

  ServerDataDTO.fromJson(Map<String, dynamic> json) {
    serverName = json['server_name'];
    if (json['server_data'] != null) {
      episode = <EpisodeDTO>[];
      json['server_data'].forEach((v) {
        episode!.add(EpisodeDTO.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['server_name'] = serverName;
    if (episode != null) {
      data['server_data'] = episode!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  ServerData toServerData() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['server_name'] = serverName;
    if (episode != null) {
      data['server_data'] = episode!.map((v) => v.toJson()).toList();
    }
    return ServerData(
      serverName: serverName,
      episode: episode?.map((v) => v.toEpisode()).toList(),
    );
  }
}