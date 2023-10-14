import 'package:ebroker/utils/Extensions/lib/adaptive_type.dart';

class ArticleModel {
  int? id;
  String? image;
  String? title;
  String? description;

  ArticleModel({this.id, this.image, this.title, this.description});

  ArticleModel.fromJson(Map<String, dynamic> json) {
    id = Adapter.forceInt(json['id']);
    image = json['image'];
    title = json['title'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['title'] = title;
    data['description'] = description;
    return data;
  }
}
