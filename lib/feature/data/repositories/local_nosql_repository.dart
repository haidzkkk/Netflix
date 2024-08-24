
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:spotify/feature/data/local/hive_manager.dart';
import 'package:spotify/feature/data/models/db_local/movie_local.dart';

import '../../commons/contants/app_constants.dart';
import '../../commons/utility/utils.dart';

class LocalNosqlRepository{
  HiveManager hiveManager;
  LocalNosqlRepository(this.hiveManager);

   Future<MovieLocal> getMovieHistory({required String id}) async{
    try {
      final Box box = HiveManager().getBox(AppConstants.movieHistoryBoxName);
      final String jsonMovie = box.get(id);
      return MovieLocal.fromJson(jsonDecode(jsonMovie));
    } catch (_) {
      printData(_.toString());
      await Hive.deleteBoxFromDisk(AppConstants.movieHistoryBoxName);
      throw Exception("Get data error");
    }
  }

  Future<void> saveMovieHistory({required MovieLocal body}) async {
    final Box box = HiveManager().getBox(AppConstants.movieHistoryBoxName);
    box.put(body.id, jsonEncode(body.toJson()));
  }
}