import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:path/path.dart';

class FileUtil{
  static double bytesToMb(double bytes){
    return bytes / (1024 * 1024);
  }

}

extension FileExt on File{
  String get name{
    String fileName = basename(path);

    return fileName.substring(0, fileName.indexOf("."));
  }
  String get fileName{
    return basename(path);
  }
}

extension DirectoryExt on Directory{
  String get name{
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