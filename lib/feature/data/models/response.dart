
class Response {
  int statusCode;
  String? statusText;
  Map<String, dynamic> body;
  Map<String, String>? headers;

  Response({
    required this.statusCode,
    Map<String, dynamic>? body,
    this.statusText,
    this.headers,
  }) : body = body ?? {};

  @override
  String toString() {
    return "statusCode: $statusCode"
        "statusText: $statusText"
        "body: $body"
        "headers: $headers";
  }
}