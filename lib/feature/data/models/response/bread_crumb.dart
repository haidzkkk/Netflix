
class BreadCrumb {
  String? name;
  String? slug;
  bool? isCurrent;
  int? position;

  BreadCrumb({this.name, this.slug, this.isCurrent, this.position});

  BreadCrumb.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    slug = json['slug'];
    isCurrent = json['isCurrent'];
    position = json['position'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['slug'] = slug;
    data['isCurrent'] = isCurrent;
    data['position'] = position;
    return data;
  }
}