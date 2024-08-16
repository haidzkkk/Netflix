
import '../../../commons/contants/app_constants.dart';
import '../../../commons/utility/utils.dart';
import '../response/category.dart';
import '../response/modified.dart';

class MovieInfo {
  Modified? created;
  Modified? modified;
  String? sId;
  String? name;
  String? slug;
  String? originName;
  String? content;
  String? type;
  String? status;
  String? posterUrl;
  String? thumbUrl;
  bool? isCopyright;
  bool? subDocquyen;
  bool? chieurap;
  String? trailerUrl;
  String? time;
  String? episodeCurrent;
  String? episodeTotal;
  String? quality;
  String? lang;
  String? notify;
  String? showtimes;
  int? year;
  int? view;
  List<String>? actor;
  List<String>? director;
  List<Category>? category;
  List<Category>? country;

  MovieInfo(
      {this.created,
        this.modified,
        this.sId,
        this.name,
        this.slug,
        this.originName,
        this.content,
        this.type,
        this.status,
        this.posterUrl,
        this.thumbUrl,
        this.isCopyright,
        this.subDocquyen,
        this.chieurap,
        this.trailerUrl,
        this.time,
        this.episodeCurrent,
        this.episodeTotal,
        this.quality,
        this.lang,
        this.notify,
        this.showtimes,
        this.year,
        this.view,
        this.actor,
        this.director,
        this.category,
        this.country});

  String get getThumbUrl => hasDomainUrl(thumbUrl ?? "")
      ? "$thumbUrl"
      : "${AppConstants.BASE_URL_IMAGE}/$thumbUrl" ;

  String get getPosterUrl => hasDomainUrl(posterUrl ?? "")
      ? "$posterUrl"
      : "${AppConstants.BASE_URL_IMAGE}/$posterUrl" ;


  MovieInfo.fromJson(Map<String, dynamic> json) {
    created =
    json['created'] != null ? Modified.fromJson(json['created']) : null;
    modified = json['modified'] != null
        ? Modified.fromJson(json['modified'])
        : null;
    sId = json['_id'];
    name = json['name'];
    slug = json['slug'];
    originName = json['origin_name'];
    content = json['content'];
    type = json['type'];
    status = json['status'];
    posterUrl = json['poster_url'];
    thumbUrl = json['thumb_url'];
    isCopyright = json['is_copyright'];
    subDocquyen = json['sub_docquyen'];
    chieurap = json['chieurap'];
    trailerUrl = json['trailer_url'];
    time = json['time'];
    episodeCurrent = json['episode_current'];
    episodeTotal = json['episode_total'];
    quality = json['quality'];
    lang = json['lang'];
    notify = json['notify'];
    showtimes = json['showtimes'];
    year = json['year'];
    view = json['view'];
    actor = json['actor'].cast<String>();
    director = json['director'].cast<String>();
    if (json['category'] != null) {
      category = <Category>[];
      json['category'].forEach((v) {
        category!.add(Category.fromJson(v));
      });
    }
    if (json['country'] != null) {
      country = <Category>[];
      json['country'].forEach((v) {
        country!.add(Category.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (created != null) {
      data['created'] = created!.toJson();
    }
    if (modified != null) {
      data['modified'] = modified!.toJson();
    }
    data['_id'] = sId;
    data['name'] = name;
    data['slug'] = slug;
    data['origin_name'] = originName;
    data['content'] = content;
    data['type'] = type;
    data['status'] = status;
    data['poster_url'] = posterUrl;
    data['thumb_url'] = thumbUrl;
    data['is_copyright'] = isCopyright;
    data['sub_docquyen'] = subDocquyen;
    data['chieurap'] = chieurap;
    data['trailer_url'] = trailerUrl;
    data['time'] = time;
    data['episode_current'] = episodeCurrent;
    data['episode_total'] = episodeTotal;
    data['quality'] = quality;
    data['lang'] = lang;
    data['notify'] = notify;
    data['showtimes'] = showtimes;
    data['year'] = year;
    data['view'] = view;
    data['actor'] = actor;
    data['director'] = director;
    if (category != null) {
      data['category'] = category!.map((v) => v.toJson()).toList();
    }
    if (country != null) {
      data['country'] = country!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}