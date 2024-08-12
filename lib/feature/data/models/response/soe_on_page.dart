
class SeoOnPage {
  String? ogType;
  String? titleHead;
  String? descriptionHead;
  List<String>? ogImage;
  String? ogUrl;

  SeoOnPage(
      {this.ogType,
        this.titleHead,
        this.descriptionHead,
        this.ogImage,
        this.ogUrl});

  SeoOnPage.fromJson(Map<String, dynamic> json) {
    ogType = json['og_type'];
    titleHead = json['titleHead'];
    descriptionHead = json['descriptionHead'];
    ogImage = json['og_image'].cast<String>();
    ogUrl = json['og_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['og_type'] = ogType;
    data['titleHead'] = titleHead;
    data['descriptionHead'] = descriptionHead;
    data['og_image'] = ogImage;
    data['og_url'] = ogUrl;
    return data;
  }
}