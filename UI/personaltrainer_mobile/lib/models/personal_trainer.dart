import 'package:json_annotation/json_annotation.dart';

part 'personal_trainer.g.dart';

@JsonSerializable(explicitToJson: true)
class PersonalTrainer {
  int? id;
  int? userId;
  String? userFirstName;
  int? yearsOfExperience;
  bool? isActive;
  String? certifications;

  PersonalTrainer({
    this.id,
    this.userId,
    this.userFirstName,
    this.yearsOfExperience,
    this.isActive,
    this.certifications,
  });

  factory PersonalTrainer.fromJson(Map<String, dynamic> json) =>
      _$PersonalTrainerFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalTrainerToJson(this);
}
