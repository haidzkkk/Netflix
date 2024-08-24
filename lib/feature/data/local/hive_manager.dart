import 'package:hive/hive.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:path_provider/path_provider.dart';

class HiveManager {

  Future<void> init() async {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
    if (!Hive.isBoxOpen(AppConstants.movieHistoryBoxName)) {
      await Hive.openBox(AppConstants.movieHistoryBoxName);
    }
    if (!Hive.isBoxOpen(AppConstants.searchBoxName)) {
      await Hive.openBox(AppConstants.searchBoxName);
    }
  }

  closeBox() async{
    Hive.close();
  }

  Box getBox(String boxName){
    return Hive.box(boxName);
  }

}