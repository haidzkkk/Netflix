class MovieResponse {
  bool? status;
  List<Movie>? items;
  Pagination? pagination;

  MovieResponse({this.status, this.items, this.pagination});

  MovieResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['items'] != null) {
      items = <Movie>[];
      json['items'].forEach((v) {
        items!.add(Movie.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class Movie {
  Modified? modified;
  String? sId;
  String? name;
  String? slug;
  String? originName;
  String? posterUrl;
  String? thumbUrl;
  int? year;

  Movie(
      {this.modified,
        this.sId,
        this.name,
        this.slug,
        this.originName,
        this.posterUrl,
        this.thumbUrl,
        this.year});

  Movie.fromJson(Map<String, dynamic> json) {
    modified = json['modified'] != null
        ? Modified.fromJson(json['modified'])
        : null;
    sId = json['_id'];
    name = json['name'];
    slug = json['slug'];
    originName = json['origin_name'];
    posterUrl = json['poster_url'];
    thumbUrl = json['thumb_url'];
    year = json['year'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (modified != null) {
      data['modified'] = modified!.toJson();
    }
    data['_id'] = sId;
    data['name'] = name;
    data['slug'] = slug;
    data['origin_name'] = originName;
    data['poster_url'] = posterUrl;
    data['thumb_url'] = thumbUrl;
    data['year'] = year;
    return data;
  }
}

class Modified {
  String? time;

  Modified({this.time});

  Modified.fromJson(Map<String, dynamic> json) {
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time'] = time;
    return data;
  }
}

class Pagination {
  int? totalItems;
  int? totalItemsPerPage;
  int? currentPage;
  int? totalPages;

  Pagination(
      {this.totalItems,
        this.totalItemsPerPage,
        this.currentPage,
        this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    totalItems = json['totalItems'];
    totalItemsPerPage = json['totalItemsPerPage'];
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalItems'] = totalItems;
    data['totalItemsPerPage'] = totalItemsPerPage;
    data['currentPage'] = currentPage;
    data['totalPages'] = totalPages;
    return data;
  }
}
