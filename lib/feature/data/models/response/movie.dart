import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:spotify/feature/commons/contants/app_constants.dart';

import '../../../commons/utility/utils.dart';
import '../movie_detail/movie_info.dart';
import 'category.dart';
import 'modified.dart';

@immutable
class Movie extends Equatable{
  Modified? modified;
  String? id;
  String? name;
  String? slug;
  String? originName;
  String? type;
  String? posterUrl;
  String? thumbUrl;
  bool? subDocquyen;
  bool? chieurap;
  String? time;
  String? episodeCurrent;
  String? quality;
  String? lang;
  int? year;
  List<Category>? category;
  List<Category>? country;


  Movie(
      {this.modified,
        this.id,
        this.name,
        this.slug,
        this.originName,
        this.type,
        this.posterUrl,
        this.thumbUrl,
        this.subDocquyen,
        this.chieurap,
        this.time,
        this.episodeCurrent,
        this.quality,
        this.lang,
        this.year,
        this.category,
        this.country
      });

  String get getThumbUrl => hasDomainUrl(thumbUrl ?? "")
      ? "$thumbUrl"
      : "${AppConstants.BASE_URL_IMAGE}/$thumbUrl" ;

  String get getPosterUrl => hasDomainUrl(posterUrl ?? "")
      ? "$posterUrl"
      : "${AppConstants.BASE_URL_IMAGE}/$posterUrl" ;

  Color? _color;
  set color(Color? colorData) => _color = colorData;
  Future<Color?> getColor() async{
    if(_color != null){
      return _color;
    }
    _color = await generateColorImageUrl(getThumbUrl);
    return _color;
  }

  Movie.fromJson(Map<String, dynamic> json) {
    modified = json['modified'] != null
        ? Modified.fromJson(json['modified'])
        : null;
    id = json['_id'];
    name = json['name'];
    slug = json['slug'];
    originName = json['origin_name'];
    type = json['type'];
    posterUrl = json['poster_url'];
    thumbUrl = json['thumb_url'];
    subDocquyen = json['sub_docquyen'];
    chieurap = json['chieurap'];
    time = json['time'];
    episodeCurrent = json['episode_current'];
    quality = json['quality'];
    lang = json['lang'];
    year = json['year'];
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

  MovieInfo toMovieInfo(){
    return MovieInfo(
      modified: modified,
      name: name,
      slug: slug,
      originName: originName,
      type: type,
      posterUrl: posterUrl,
      thumbUrl: thumbUrl,
      subDocquyen: subDocquyen,
      chieurap: chieurap,
      time: time,
      episodeCurrent: episodeCurrent,
      quality: quality,
      lang: lang,
      year: year,
      category: category,
      country: country,
      color: _color
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (modified != null) {
      data['modified'] = modified!.toJson();
    }
    data['_id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['origin_name'] = originName;
    data['type'] = type;
    data['poster_url'] = posterUrl;
    data['thumb_url'] = thumbUrl;
    data['sub_docquyen'] = subDocquyen;
    data['chieurap'] = chieurap;
    data['time'] = time;
    data['episode_current'] = episodeCurrent;
    data['quality'] = quality;
    data['lang'] = lang;
    data['year'] = year;
    if (category != null) {
      data['category'] = category!.map((v) => v.toJson()).toList();
    }
    if (country != null) {
      data['country'] = country!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  List<Object?> get props => [id];
}


