import 'package:spotify/feature/data/models/category.dart';

class CategoryDTO {
  String? id;
  String? name;
  String? slug;

  CategoryDTO({this.id, this.name, this.slug});

  CategoryDTO.fromJson(Map<String, dynamic> json) {
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
