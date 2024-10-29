
import 'package:spotify/feature/data/models/episode.dart';

class EpisodeDTO {
  String? name;
  String? slug;
  String? filename;
  String? linkEmbed;
  String? linkM3u8;

  EpisodeDTO(
      {this.name, this.slug, this.filename, this.linkEmbed, this.linkM3u8});

  EpisodeDTO.fromJson(Map<String, dynamic> json) {
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

  Episode toEpisode() {
    return Episode(
      name: name,
      slug: slug,
      filename: filename,
      linkEmbed: linkEmbed,
      linkM3u8: linkM3u8,
    );
  }
}