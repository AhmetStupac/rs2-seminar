import 'package:json_annotation/json_annotation.dart';

part 'training.g.dart';

@JsonSerializable()
class Training {
  int? id;
  String? name; // nije se dodalo u exercise.g.dart
  String? description;
  int? duration; // trajanje u minutama
  int? clientId;
  int? personalTrainerId;

  // 1. korak preimenovati part dio, naziv klase, ctor itd.
  //2.  korak popisati prop i dodati u ctor
  //3. korak save projekat pa pokrenuti -> flutter pub run build_runner build
  //4. korak kreirati provider za ovaj model

  Training({
    this.id,
    this.name,
    this.description,
    this.duration,
    this.clientId,
    this.personalTrainerId,
  });

  factory Training.fromJson(Map<String, dynamic> json) =>
      _$TrainingFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingToJson(this);
}
