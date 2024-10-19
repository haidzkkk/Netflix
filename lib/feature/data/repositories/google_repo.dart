
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spotify/feature/commons/hepler/google_service.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/drive/v3.dart' as drive;

class GoogleRepo{
  GoogleService googleService;
  GoogleRepo(this.googleService);

  Future<GoogleSignInAccount?> getCurrentUser()
    async => googleService.getCurrentUser();

  Future<GoogleSignInAccount?> signIn()
    async => googleService.signIn();

  Future<GoogleSignInAccount?> logout()
    async => googleService.logout();

  Future<List<drive.File>> getListFile({String? fileName})
    async => googleService.getListFile(fileName: fileName);

  Future<drive.File?> uploadToDrive({required String fileName, required String jsonData})
    async => googleService.uploadToDrive(fileName: fileName, jsonData: jsonData,);

  Future<Map<String, dynamic>?> getFileContent({required String fileId})
    async => googleService.getFileContent(fileId,);

}