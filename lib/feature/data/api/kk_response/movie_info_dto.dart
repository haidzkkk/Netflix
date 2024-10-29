import 'dart:math';
import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/commons/utility/utils.dart';
import 'package:spotify/feature/data/api/kk_response/category_dto.dart';
import 'package:spotify/feature/data/api/kk_response/country_dto.dart';
import 'package:spotify/feature/data/api/kk_response/modified_dto.dart';
import 'package:spotify/feature/data/api/kk_response/server_dto.dart';
import 'package:spotify/feature/data/api/server_type.dart';
import 'package:spotify/feature/data/models/movie_info.dart';

class MovieInfoDTO {
  ModifiedDTO? created;
  ModifiedDTO? modified;
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
  List<CategoryDTO>? category;
  List<CountryDTO>? country;
  List<ServerDataDTO>? servers;

  MovieInfoDTO(
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
        this.country,
        this.servers,
      });

  String get getThumbUrl => hasDomainUrl(thumbUrl ?? "")
      ? "$thumbUrl"
      : "${AppConstants.KK_BASE_URL_IMAGE}/$thumbUrl" ;

  String get getPosterUrl => hasDomainUrl(posterUrl ?? "")
      ? "$posterUrl"
      : "${AppConstants.KK_BASE_URL_IMAGE}/$posterUrl" ;


  MovieInfoDTO.fromJson(Map<String, dynamic> json) {
    created =
    json['created'] != null ? ModifiedDTO.fromJson(json['created']) : null;
    modified = json['modified'] != null
        ? ModifiedDTO.fromJson(json['modified'])
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
    view = Random().nextInt(10000000);
    actor = json['actor']?.cast<String>();
    director = json['director']?.cast<String>();
    if (json['category'] != null) {
      category = <CategoryDTO>[];
      json['category'].forEach((v) {
        category!.add(CategoryDTO.fromJson(v));
      });
    }
    if (json['country'] != null) {
      country = <CountryDTO>[];
      json['country'].forEach((v) {
        country!.add(CountryDTO.fromJson(v));
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

  MovieInfo toMovieInfo() {
    return MovieInfo(
      created : created?.toModified(),
      modified : modified?.toModified(),
      sId : sId,
      name : name,
      slug : slug,
      originName : originName,
      content : content,
      type : type,
      status : status,
      posterUrl : getPosterUrl,
      thumbUrl : getThumbUrl,
      isCopyright : isCopyright,
      subDocquyen : subDocquyen,
      chieurap : chieurap,
      trailerUrl : trailerUrl,
      time : time,
      episodeCurrent : episodeCurrent,
      episodeTotal : episodeTotal,
      quality : quality,
      lang : lang,
      notify : notify,
      showtimes : showtimes,
      year : year,
      view : view,
      actor : actor,
      director : director,
      categories : category?.map((e) => e.toCategory()).toList(),
      countries : country?.map((e) => e.toCategory()).toList(),
      servers : servers?.map((e) => e.toServerData()).toList(),
      serverType : ServerType.kkPhim,
    );
  }
}