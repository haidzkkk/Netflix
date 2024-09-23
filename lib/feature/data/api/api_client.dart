import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/commons/utility/connect_util.dart';

import '../../commons/utility/utils.dart';
import '../models/response.dart' as model;

class ApiClient {
  ApiClient({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  final int timeoutInSeconds = 30;

  Future<model.Response> getData({
    required String uri,
    Map<String, String>? query,
    Map<String, String>? headers,
    String? baseUrl,
  }) async{
    if(await ConnectUtil.getStateNetwork() == false){
    // if(true){
      return model.Response(statusCode: 1, statusText: "noInternetMessage", body: {});
    }

    if(query != null ){
      printData("====> API Call: ${Uri.parse((baseUrl ?? AppConstants.BASE_URL) + uri)
          .replace(queryParameters: query)}"
          "\nHeader: $headers");
    }else{
      printData('====> API Call: ${baseUrl ?? AppConstants.BASE_URL}$uri\nHeader: $headers');
    }

    try {
      http.Response response = await http.get(
        Uri.parse((baseUrl ?? AppConstants.BASE_URL) + uri).replace(queryParameters: query),
        headers: headers,
      ).timeout(Duration(seconds: timeoutInSeconds));

      return handleResponse(response, uri);
    } catch (e) {
      printData('------------${e.toString()}');
      return model.Response(statusCode: 1, statusText: "noInternetMessage", body: {});
    }
  }

  Future<model.Response> postData({
    required String uri,
    dynamic body,
    Map<String, String>? headers,
    String? baseUrl
  }) async {
    if(await ConnectUtil.getStateNetwork() == false){
      return model.Response(statusCode: 1, statusText: "noInternetMessage", body: {});
    }
    try {
      printData('====> API Call: ${baseUrl ?? AppConstants.BASE_URL}$uri\nHeader: $headers');
      printData('====> API Body: $body');

      http.Response response = await http.post(
        Uri.parse((baseUrl ?? AppConstants.BASE_URL) + uri),
        body: jsonEncode(body),
        headers: headers,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      printData('------------${e.toString()}');
      return model.Response(statusCode: 1, statusText: "noInternetMessage", body: {});
    }
  }

  Future<model.Response> putData({
    required String uri,
    dynamic body,
    Map<String, String>? headers,
    String? baseUrl
  }) async {
    if(await ConnectUtil.getStateNetwork() == false){
      return model.Response(statusCode: 1, statusText: "noInternetMessage", body: {});
    }
    try {
      printData('====> API Call: ${baseUrl ?? AppConstants.BASE_URL}$uri\nHeader: $headers');
      printData('====> API Body: $body');

      http.Response response = await http.put(
        Uri.parse((baseUrl ?? AppConstants.BASE_URL) + uri),
        body: jsonEncode(body),
        headers: headers,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return model.Response(statusCode: 1, statusText: "noInternetMessage");
    }
  }

  Future<model.Response> deleteData({
    required String uri,
    Map<String, String>? headers,
    String? baseUrl
  }) async {
    if(await ConnectUtil.getStateNetwork() == false){
      return model.Response(statusCode: 1, statusText: "noInternetMessage", body: {});
    }
    try {
      printData('====> API Call: ${AppConstants.BASE_URL}$uri\nHeader: $headers');

      http.Response response = await http.delete(
        Uri.parse(AppConstants.BASE_URL + uri),
        headers: headers,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return model.Response(statusCode: 1, statusText: "noInternetMessage");
    }
  }

  Future<model.Response> postFileMultipartData({
    required String uri,
    required Map<String, String> body,
    required List<File> files,
    Map<String, String>? headers,
    String? baseUrl
  }) async {
    if(await ConnectUtil.getStateNetwork() == false){
      return model.Response(statusCode: 1, statusText: "noInternetMessage", body: {});
    }
    try {
      printData('====> API Call: ${ baseUrl ?? AppConstants.BASE_URL}$uri\nHeader: $headers');

      List<http.MultipartFile> imageMultipartFiles = [];

      files.forEach((file) async{
        http.MultipartFile imageMultipartFile = await http.MultipartFile.fromPath(
          "files",
          file.path,
          filename: '${DateTime.now().millisecondsSinceEpoch.toString()}.png',
        );
        imageMultipartFiles.add(imageMultipartFile);
      });

      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse((baseUrl ?? AppConstants.BASE_URL) + uri));
      if(headers != null) request.headers.addAll(headers);
      request.files.addAll(imageMultipartFiles);
      request.fields.addAll(body);

      http.Response response = await http.Response.fromStream(await request.send());
      return handleResponse(response, uri);
    } catch (e) {
      return model.Response(statusCode: 1, statusText: "noInternetMessage");
    }
  }

  /// utils
  model.Response handleResponse(http.Response response, String uri) {
    dynamic body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {}
    model.Response responseData = model.Response(
      statusCode: response.statusCode,
      body: body ?? response.body,
      statusText: "",
      headers: response.headers,
    );
    printData('====> API Response: [${responseData.statusCode}] $uri\n${responseData.body}');
    return responseData;
  }
}
