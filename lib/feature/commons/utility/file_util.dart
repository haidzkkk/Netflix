import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:path/path.dart';

class FileUtil{
  static Future<Directory?> getLocalPathDownload() async{
    Directory? directory;
    if (Platform.isAndroid){
      directory = Directory("${(await getExternalStorageDirectory())?.path}/download");
    } else if (Platform.isIOS) {
    } else if (Platform.isWindows) {
    }

    if (directory != null && !await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  static Future<String?> getLocalPathToDownloadVideo({required String movieName, required String episodeName}) async{
    Directory? directory = await getLocalPathDownload();

    if(directory == null){
      return null;
    }

    Directory movieDirectory = Directory("${directory.path}/$movieName");
    if (!await movieDirectory.exists()) {
      await movieDirectory.create(recursive: true);
    }

    return "${movieDirectory.path}/$episodeName.mp4";
  }

  static Future<List<Directory>> getListMovieDownload() async{
    List<Directory> directories = [];

    Directory? directory = await getLocalPathDownload();

    if(directory != null){
      try{
        directories = directory.listSync()
            .where((element) => element is Directory)
            .map((directory) => directory as Directory).toList();
      }catch(e){
        printData("Lỗi không lấy được thư mục");
      }
    }

    return directories;
  }
}

extension DirectoryExt on Directory{
  String getName(){
    return basename(path);
  }

  Future<int> getSize() async{
    int totalSize = 0;
    try {
      if (existsSync()) {
        await for (FileSystemEntity file in list(recursive: true, followLinks: false)) {    /// recursive: duyệt thư mục con bên trong. followLinks: bỏ qua các file liên kết, nó như shortcut
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }
    } catch (e) {
      printData("Lỗi khi tính kích thước thư mục: $e");
    }

    return totalSize;
  }
}