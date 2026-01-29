import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  String? userId;
  String? user;
  String? email;
  String? message;
  DateTime? timestamp;
  String? fromUserId;
  String? from;
  String? toUserId;
  bool isPrivate;

  Message({
    this.userId,
    this.user,
    this.email,
    this.message,
    this.timestamp,
    this.fromUserId,
    this.from,
    this.toUserId,
    this.isPrivate = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class OnlineUser {
  String userId;
  String? email;
  String? connectionId;

  OnlineUser({required this.userId, this.email, this.connectionId});

  factory OnlineUser.fromJson(Map<String, dynamic> json) =>
      _$OnlineUserFromJson(json);

  Map<String, dynamic> toJson() => _$OnlineUserToJson(this);
}
