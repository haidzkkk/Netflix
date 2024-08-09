import 'package:hive/hive.dart';

class HiveManager {
  static final HiveManager _instance = HiveManager._internal();

  factory HiveManager() {
    return _instance;
  }

  HiveManager._internal();

  Future<void> init() async {
    // if (!Hive.isBoxOpen(RoomOfflineRepo.roomIdBoxName)) {
    //   await Hive.openBox(RoomOfflineRepo.roomIdBoxName);
    // }
  }

  Box getBox(String boxName) {
    return Hive.box(boxName);
  }
}