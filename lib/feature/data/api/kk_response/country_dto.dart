import 'package:spotify/feature/data/models/category.dart';

class CountryDTO {
  String? id;
  String? name;
  String? slug;

  CountryDTO({this.id, this.name, this.slug});

  CountryDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    return data;
  }

  Category toCategory() {
    return Category(
      id: id,
      name: name,
      slug: slug,
    );
  }
}
