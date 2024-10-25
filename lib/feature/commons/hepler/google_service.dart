
import 'dart:convert';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:spotify/feature/data/repositories/file_repo.dart';

class GoogleService{
  GoogleService(this.fileRepository);
  final FileRepository fileRepository;

  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope, drive.DriveApi.driveReadonlyScope],
  );

  Future<GoogleSignInAccount?> getCurrentUser() async{
    if(await googleSignIn.isSignedIn() != true) return null;
    return googleSignIn.signIn();
  }

  Future<GoogleSignInAccount?> signIn() async{
    return googleSignIn.signIn();
  }

  Future<GoogleSignInAccount?> logout() async{
    return googleSignIn.signOut();
  }

  Future<drive.DriveApi?> _getDriverApi() async{
    var currentUser = await getCurrentUser();
    final auth.AuthClient? client = await currentUser?.authHeaders.then(
          (headers) => auth.authenticatedClient(http.Client(), auth.AccessCredentials(
        auth.AccessToken('Bearer', headers['Authorization']!.split(' ')[1], DateTime.now().toUtc().add(const Duration(hours: 1))),
        null,
        [drive.DriveApi.driveFileScope],
      )),
    );
    return client == null ? null : drive.DriveApi(client);
  }

  Future<String?> _getFolderDrive(drive.DriveApi driveApi) async{
    var result = await driveApi.files.list(
      q: "mimeType='${AppConstants.backupMineType}' and name='${AppConstants.backupFolderName}'",
      spaces: 'drive',
    );

    if((result.files ?? []).isEmpty){
      final folder = await driveApi.files.create(
          drive.File()
            ..name = AppConstants.backupFolderName
            ..mimeType = AppConstants.backupMineType,
      );
      return folder.id;
    } else{
      return result.files?.first.id;
    }
  }

  Future<List<drive.File>> getListFile({String? fileName}) async{
    final driveApi = await _getDriverApi();
    if (driveApi == null) {
      printData('Sign in failed');
      return [];
    }

    String folderID = await _getFolderDrive(driveApi) ?? '';
    try{
      String query = "'$folderID' in parents and trashed = false";
      if (fileName?.isNotEmpty == true) query += " and name contains '$fileName'";


      var fileList = await driveApi.files.list(
        q: query,
        $fields: 'files(id, name, mimeType, createdTime, modifiedTime)',
      );
      return fileList.files ?? [];
    }catch(e){
      printData('Lỗi khi lấy danh sách file: $e');
      return [];
    }
  }

  Future<drive.File?> uploadToDrive({required String fileName, required String jsonData}) async{
    final driveApi = await _getDriverApi();
    if (driveApi == null) {
      printData('Sign in failed');
      return null;
    }

    String folderID = await _getFolderDrive(driveApi) ?? '';
    File fileData = await _writeJson(jsonData);
    drive.Media driverMedia = drive.Media(fileData.openRead(), fileData.lengthSync());


    try{
      drive.File? fileExists = (await getListFile(fileName: fileName)).firstOrNull;
      drive.File result;
      if(fileExists != null){
        result = await driveApi.files.update(drive.File(), fileExists.id!,
            uploadMedia: driverMedia,
            addParents: folderID,
            removeParents: folderID,
        );
      }else{
        final driveFile = drive.File()
          ..name = fileName
          ..parents = [folderID];
        result = await driveApi.files.create(driveFile, uploadMedia: driverMedia);
      }
      printData('File uploaded. file: ${result.id}');
      return result;
    } catch (e) {
      printData('Error uploading file: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getFileContent(String fileId) async {
    final driveApi = await _getDriverApi();
    if (driveApi == null) {
      return null;
    }

    try {
      drive.Media fileContent = await driveApi.files.get(fileId,
          downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

      List<int> dataStore = [];
      await for (var data in fileContent.stream) {
        dataStore.addAll(data);
      }

      String jsonString = utf8.decode(dataStore);
      return jsonDecode(jsonString);
    } catch (e) {
      printData('Lỗi khi lấy nội dung file: $e');
      return null;
    }
  }

  Future<File> _writeJson(String jsonData) async{
    String localPath = (await fileRepository.getLocalPath()).path;
    var localFile = File("$localPath/backup.json");
    return localFile.writeAsString(jsonData);
  }

}