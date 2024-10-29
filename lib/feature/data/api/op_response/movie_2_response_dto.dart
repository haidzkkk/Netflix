import 'package:spotify/feature/data/api/op_response/bread_crumb_dto.dart';
import 'package:spotify/feature/data/api/op_response/movie_info_dto.dart';
import 'package:spotify/feature/data/api/op_response/params_dto.dart';
import 'package:spotify/feature/data/api/op_response/soe_on_page_dto.dart';

class Movie2ResponseDTO {
  SeoOnPageDTO? seoOnPage;
  List<BreadCrumbDTO>? breadCrumb;
  String? titlePage;
  List<MovieInfoDTO>? items;
  ParamsDTO? params;
  String? typeList;
  String? appDomainFrontEnd;
  String? appDomainCdnImage;

  Movie2ResponseDTO(
      {this.seoOnPage,
        this.breadCrumb,
        this.titlePage,
        this.items,
        this.params,
        this.typeList,
        this.appDomainFrontEnd,
        this.appDomainCdnImage});

  Movie2ResponseDTO.fromJson(Map<String, dynamic> json) {
    seoOnPage = json['seoOnPage'] != null
        ? SeoOnPageDTO.fromJson(json['seoOnPage'])
        : null;
    if (json['breadCrumb'] != null) {
      breadCrumb = <BreadCrumbDTO>[];
      json['breadCrumb'].forEach((v) {
        breadCrumb!.add(BreadCrumbDTO.fromJson(v));
      });
    }
    titlePage = json['titlePage'];
    if (json['items'] != null) {
      items = <MovieInfoDTO>[];
      json['items'].forEach((v) {
        items!.add(MovieInfoDTO.fromJson(v));
      });
    }
    params =
    json['params'] != null ? ParamsDTO.fromJson(json['params']) : null;
    typeList = json['type_list'];
    appDomainFrontEnd = json['APP_DOMAIN_FRONTEND'];
    appDomainCdnImage = json['APP_DOMAIN_CDN_IMAGE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (seoOnPage != null) {
      data['seoOnPage'] = seoOnPage!.toJson();
    }
    if (breadCrumb != null) {
      data['breadCrumb'] = breadCrumb!.map((v) => v.toJson()).toList();
    }
    data['titlePage'] = titlePage;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (params != null) {
      data['params'] = params!.toJson();
    }
    data['type_list'] = typeList;
    data['APP_DOMAIN_FRONTEND'] = appDomainFrontEnd;
    data['APP_DOMAIN_CDN_IMAGE'] = appDomainCdnImage;
    return data;
  }
}


