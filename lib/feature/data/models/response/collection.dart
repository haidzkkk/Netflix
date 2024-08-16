import 'package:spotify/feature/data/models/response/soe_on_page.dart';
import 'bread_crumb.dart';
import 'movie.dart';

class Collection {
  SeoOnPage? seoOnPage;
  List<BreadCrumb>? breadCrumb;
  String? titlePage;
  List<Movie>? items;
  Params? params;
  String? typeList;
  String? appDomainFrontEnd;
  String? appDomainCdnImage;

  Collection(
      {this.seoOnPage,
        this.breadCrumb,
        this.titlePage,
        this.items,
        this.params,
        this.typeList,
        this.appDomainFrontEnd,
        this.appDomainCdnImage});

  Collection.fromJson(Map<String, dynamic> json) {
    seoOnPage = json['seoOnPage'] != null
        ? SeoOnPage.fromJson(json['seoOnPage'])
        : null;
    if (json['breadCrumb'] != null) {
      breadCrumb = <BreadCrumb>[];
      json['breadCrumb'].forEach((v) {
        breadCrumb!.add(BreadCrumb.fromJson(v));
      });
    }
    titlePage = json['titlePage'];
    if (json['items'] != null) {
      items = <Movie>[];
      json['items'].forEach((v) {
        items!.add(Movie.fromJson(v));
      });
    }
    params =
    json['params'] != null ? Params.fromJson(json['params']) : null;
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

class Params {
  String? typeSlug;
  List<String>? filterCategory;
  List<String>? filterCountry;
  String? filterYear;
  String? filterType;
  String? sortField;
  String? sortType;
  Pagination? pagination;

  Params(
      {this.typeSlug,
        this.filterCategory,
        this.filterCountry,
        this.filterYear,
        this.filterType,
        this.sortField,
        this.sortType,
        this.pagination});

  Params.fromJson(Map<String, dynamic> json) {
    typeSlug = json['type_slug'];
    filterCategory = json['filterCategory'].cast<String>();
    filterCountry = json['filterCountry'].cast<String>();
    filterYear = json['filterYear'];
    filterType = json['filterType'];
    sortField = json['sortField'];
    sortType = json['sortType'];
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type_slug'] = typeSlug;
    data['filterCategory'] = filterCategory;
    data['filterCountry'] = filterCountry;
    data['filterYear'] = filterYear;
    data['filterType'] = filterType;
    data['sortField'] = sortField;
    data['sortType'] = sortType;
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
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
