import 'package:json_annotation/json_annotation.dart';
import 'package:personaltrainer_mobile/models/image.dart';

part 'gym.g.dart';

@JsonSerializable()
class Gym {
  int? id;
  String? name;
  String? address;
  String? city;
  String? country;
  String? email;
  String? phoneNumber;
  String? workTime;
  int? imageId;
  Image? image;
  String? imageUrl;

  Gym({
    this.id,
    this.name,
    this.address,
    this.city,
    this.country,
    this.email,
    this.phoneNumber,
    this.workTime,
    this.imageId,
    this.image,
    this.imageUrl,
  });

  factory Gym.fromJson(Map<String, dynamic> json) => _$GymFromJson(json);

  Map<String, dynamic> toJson() => _$GymToJson(this);
}
