import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable(createFactory: false)
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

  factory Message.fromJson(Map<String, dynamic> json) {
    // Handle both PascalCase (C# backend) and camelCase
    // Also handle MessageHub DTO format with 'content', 'senderId', 'recipientId', 'messageSent'
    return Message(
      userId:
          json['userId']?.toString() ??
          json['UserId']?.toString() ??
          json['senderId']?.toString() ??
          json['SenderId']?.toString(),
      user:
          json['user']?.toString() ??
          json['User']?.toString() ??
          json['senderDisplayName']?.toString() ??
          json['SenderDisplayName']?.toString(),
      email: json['email']?.toString() ?? json['Email']?.toString(),
      message:
          json['message']?.toString() ??
          json['Message']?.toString() ??
          json['content']?.toString() ??
          json['Content']?.toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'].toString())
          : (json['Timestamp'] != null
                ? DateTime.parse(json['Timestamp'].toString())
                : (json['messageSent'] != null
                      ? DateTime.parse(json['messageSent'].toString())
                      : (json['MessageSent'] != null
                            ? DateTime.parse(json['MessageSent'].toString())
                            : null))),
      fromUserId:
          json['fromUserId']?.toString() ??
          json['FromUserId']?.toString() ??
          json['senderId']?.toString() ??
          json['SenderId']?.toString(),
      from:
          json['from']?.toString() ??
          json['From']?.toString() ??
          json['senderDisplayName']?.toString() ??
          json['SenderDisplayName']?.toString(),
      toUserId:
          json['toUserId']?.toString() ??
          json['ToUserId']?.toString() ??
          json['recipientId']?.toString() ??
          json['RecipientId']?.toString(),
      isPrivate: json['isPrivate'] ?? json['IsPrivate'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable(createFactory: false)
class OnlineUser {
  @JsonKey(name: 'userId', defaultValue: '')
  String userId;

  @JsonKey(name: 'email')
  String? email;

  @JsonKey(name: 'connectionId')
  String? connectionId;

  @JsonKey(name: 'firstName')
  String? firstName;

  @JsonKey(name: 'lastName')
  String? lastName;

  OnlineUser({
    required this.userId,
    this.email,
    this.connectionId,
    this.firstName,
    this.lastName,
  });

  factory OnlineUser.fromJson(Map<String, dynamic> json) {
    // Handle both PascalCase (C# backend) and camelCase
    return OnlineUser(
      userId: json['userId']?.toString() ?? json['UserId']?.toString() ?? '',
      email: json['email']?.toString() ?? json['Email']?.toString(),
      connectionId:
          json['connectionId']?.toString() ?? json['ConnectionId']?.toString(),
      firstName:
          json['firstName']?.toString() ??
          json['FirstName']?.toString() ??
          json['firstname']?.toString(),
      lastName:
          json['lastName']?.toString() ??
          json['LastName']?.toString() ??
          json['lastname']?.toString(),
    );
  }

  String get displayName {
    if (firstName != null && firstName!.isNotEmpty) {
      if (lastName != null && lastName!.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName!;
    }
    return email ?? 'User $userId';
  }

  Map<String, dynamic> toJson() => _$OnlineUserToJson(this);
}
