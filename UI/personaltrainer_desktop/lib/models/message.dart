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
  @JsonKey(name: 'userId', defaultValue: '')
  String userId;
  
  @JsonKey(name: 'email')
  String? email;
  
  @JsonKey(name: 'connectionId')
  String? connectionId;

  OnlineUser({required this.userId, this.email, this.connectionId});

  factory OnlineUser.fromJson(Map<String, dynamic> json) {
    // Handle both PascalCase (C# backend) and camelCase
    return OnlineUser(
      userId: json['userId']?.toString() ?? json['UserId']?.toString() ?? '',
      email: json['email']?.toString() ?? json['Email']?.toString(),
      connectionId: json['connectionId']?.toString() ?? json['ConnectionId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => _$OnlineUserToJson(this);
}
