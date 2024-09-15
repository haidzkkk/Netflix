class MovieStatusDownload {
  String? id;
  String? movieId;
  String? movieName;
  String? movieSlug;
  String? name;
  String? slug;
  Status? status;
  String? localPath;
  String? url;
  int? totalSecondTime;
  int? currentSecondTime;
  int? executeProcess;

  MovieStatusDownload(
      {this.currentSecondTime,
        this.executeProcess,
        this.localPath,
        this.name,
        this.movieId,
        this.movieName,
        this.movieSlug,
        this.slug,
        this.id,
        this.status,
        this.totalSecondTime,
        this.url});

  MovieStatusDownload.fromJson(Map<String, dynamic> json) {
    currentSecondTime = json['currentSecondTime'];
    executeProcess = json['executeProcess'];
    localPath = json['localPath'];
    name = json['name'];
    movieId = json['movieId'];
    movieName = json['movieName'];
    movieSlug = json['movieSlug'];
    slug = json['slug'];
    id = json['id'];
    status = json['status'] != null ? Status.fromJson(json['status']) : null;
    totalSecondTime = json['totalSecondTime'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currentSecondTime'] = currentSecondTime;
    data['executeProcess'] = executeProcess;
    data['localPath'] = localPath;
    data['name'] = name;
    data['movieId'] = movieId;
    data['movieName'] = movieName;
    data['movieSlug'] = movieSlug;
    data['slug'] = slug;
    data['id'] = id;
    if (status != null) {
      data['status'] = status!.toJson();
    }
    data['totalSecondTime'] = totalSecondTime;
    data['url'] = url;
    return data;
  }
}

class Status {
  static const String INITIALIZATION = "INITIALIZATION";
  static const String SUCCESS = "SUCCESS";
  static const String ERROR = "ERROR";
  static const String LOADING = "LOADING";

  String? data;
  String? status;

  Status({this.data, this.status});

  Status.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data;
    data['status'] = status;
    return data;
  }
}
