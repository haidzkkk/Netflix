
import 'dart:io';

import 'package:spotify/feature/commons/utility/file_util.dart';

class FileMovieEpisode{
  Directory movie;
  List<File> episode;

  FileMovieEpisode({required this.movie, required this.episode});

  Map<String, File> get mapEpisode => Map.fromEntries(episode.map((episode){
    return MapEntry(episode.name, episode);
  }));
}