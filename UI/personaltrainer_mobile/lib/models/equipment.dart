import 'package:json_annotation/json_annotation.dart';

part 'equipment.g.dart';

@JsonSerializable()
class Equipment {
  int? id;
  String? name; // nije se dodalo u exercise.g.dart

  // 1. korak preimenovati part dio, naziv klase, ctor itd.
  //2.  korak popisati prop i dodati u ctor
  //3. korak save projekat pa pokrenuti -> flutter pub run build_runner build
  //4. korak kreirati provider za ovaj model

  Equipment({this.id, this.name});

  factory Equipment.fromJson(Map<String, dynamic> json) =>
      _$EquipmentFromJson(json);

  Map<String, dynamic> toJson() => _$EquipmentToJson(this);
}
