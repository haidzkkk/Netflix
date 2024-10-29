
class Data<T>{
  int? statusCode;
  String? msg;
  T? data;
  int? pageIndex;
  bool? isLastPage;

  Data({this.statusCode, this.data, this.pageIndex, this.isLastPage, this.msg});
}