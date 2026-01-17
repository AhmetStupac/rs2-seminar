import 'package:json_annotation/json_annotation.dart';

part 'image.g.dart';

@JsonSerializable()
class Image {
  int? id;
  String? name;
  String? url;
  int? size;
  bool? isHeader;
  int? userId;

  // 1. korak preimenovati part dio, naziv klase, ctor itd.
  //2.  korak popisati prop i dodati u ctor
  //3. korak save projekat pa pokrenuti -> flutter pub run buid_runner build
  //4. korak kreirati provider za ovaj model

  Image({this.id, this.name, this.url, this.size, this.isHeader, this.userId});

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);

  Map<String, dynamic> toJson() => _$ImageToJson(this);
}
