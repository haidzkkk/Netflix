
import 'package:spotify/feature/data/models/entity/episode_download.dart';
import 'package:spotify/feature/data/models/entity/episode_local.dart';

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