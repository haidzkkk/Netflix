
import 'package:spotify/feature/data/models/entity/episode_download.dart';
import 'package:spotify/feature/data/models/episode.dart';

class ServerData {
  static const String SERVER_NAME_LOCAL = "Local";

  String? serverName;
  List<Episode>? episodes;

  ServerData({this.serverName, this.episodes}){

    sortEpisode();
  }

  factory ServerData.fromJson(Map<String, dynamic> json) {
    return ServerData(
      serverName: json['server_name'],
      episodes: json['server_data']?.map((v) {
        return Episode.fromJson(v);
      }).toList,
    );
  }

  factory ServerData.fromEpisodeLocal(Map<String, EpisodeDownload>? episodesDownload) {
    return ServerData(
      serverName: SERVER_NAME_LOCAL,
      episodes: episodesDownload?.values.toList().map((episodeDownload){
        return episodeDownload.toEpisode()..episodesDownload = episodeDownload;
      }).toList(),
    );
  }

  void sortEpisode(){
    // List<Episode> data = episodes ?? [];
    // for(int i = 1; i < data.length; i++){
    //   Episode key = data[i];
    //   int j = i - 1;
    //
    //   while(j >= 0 && int.parse(data[j].getNumberName()) > int.parse(key.getNumberName())){
    //     data[j + 1] = data[j];
    //     j--;
    //   }
    //   data[j + 1] = key;
    // }
    episodes?.sort((a, b) {
      return (int.tryParse(a.getNumberName()) ?? 0).compareTo(int.tryParse(b.getNumberName()) ?? 0);
    },);
  }
}