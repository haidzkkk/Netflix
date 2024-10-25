import 'package:http/http.dart' as http;

class ApiClientGoogle extends http.BaseClient{
  final Map<String, String> headers;
  ApiClientGoogle({required this.headers});

  final http.Client _client = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(headers));
  }

  @override
  void close() {
    _client.close();
  }
}