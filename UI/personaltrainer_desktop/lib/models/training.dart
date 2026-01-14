import 'package:json_annotation/json_annotation.dart';

part 'training.g.dart';

@JsonSerializable()
class Training {
  int? id;
  String? name; // nije se dodalo u exercise.g.dart
  String? description;
  int? duration; // trajanje u minutama
  String? client;
  String? personalTrainer;

  // 1. korak preimenovati part dio, naziv klase, ctor itd.
  //2.  korak popisati prop i dodati u ctor 
  //3. korak save projekat pa pokrenuti build_runner
  //4. korak kreirati provider za ovaj model

  Training({this.id, this.name,this.description, this.duration, this.client, this.personalTrainer});
  
  factory Training.fromJson(Map<String, dynamic> json) =>
      _$TrainingFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingToJson(this);
}
