
import 'dart:math';
import 'dart:ui';

import 'package:spotify/feature/data/api/server_type.dart';
import 'package:spotify/feature/data/models/modified.dart';

import 'package:spotify/feature/data/models/category.dart';
import 'package:spotify/feature/data/models/server_data.dart';

import 'package:spotify/feature/commons/contants/app_constants.dart';
import 'package:spotify/feature/commons/utility/utils.dart';

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
  List<Category>? categories;
  List<Category>? countries;
  List<ServerData>? servers;

  ServerType serverType;

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
        this.categories,
        this.countries,
        this.servers,
        this.color,
        required this.serverType
      });

  Color? color;
  Future<Color?> fetchColor() async{
    if(color != null || thumbUrl?.isNotEmpty != true){
      return color;
    }
    color = await generateColorImageUrl(thumbUrl!);
    return color;
  }

  MovieInfo.fromJson(Map<String, dynamic> json, this.serverType) {
    created = json['created'] != null ? Modified.fromJson(json['created']) : null;
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
    view = Random().nextInt(10000000);
    actor = json['actor'] != null ? (json['actor'].cast<String>()) : [];
    director = json['director'] != null ? (json['director'].cast<String>()) : [];
    if (json['category'] != null) {
      categories = <Category>[];
      json['category'].forEach((v) {
        categories!.add(Category.fromJson(v));
      });
    }
    if (json['country'] != null) {
      countries = <Category>[];
      json['country'].forEach((v) {
        countries!.add(Category.fromJson(v));
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
    if (categories != null) {
      data['category'] = categories!.map((v) => v.toJson()).toList();
    }
    if (countries != null) {
      data['country'] = countries!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  MovieInfo copy() {
    return MovieInfo(
      sId: sId,
      name: name,
      slug: slug,
      originName: originName,
      content: content,
      type: type,
      status: status,
      posterUrl: posterUrl,
      thumbUrl: thumbUrl,
      isCopyright: isCopyright,
      subDocquyen: subDocquyen,
      chieurap: chieurap,
      trailerUrl: trailerUrl,
      time: time,
      episodeCurrent: episodeCurrent,
      episodeTotal: episodeTotal,
      quality: quality,
      lang: lang,
      notify: notify,
      showtimes: showtimes,
      year: year,
      view: view,
      actor: actor != null ? List<String>.from(actor!) : null,
      director: director != null ? List<String>.from(director!) : null,
      categories: categories,
      countries: countries,
      servers: servers,
      color: color,
      serverType: serverType,
    );
  }

}