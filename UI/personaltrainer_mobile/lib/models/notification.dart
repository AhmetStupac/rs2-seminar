class NotificationItem {
  int? id;
  String? title;
  String? message;
  String? type;
  bool isRead;
  DateTime? createdAt;
  DateTime? readAt;

  NotificationItem({
    this.id,
    this.title,
    this.message,
    this.type,
    this.isRead = false,
    this.createdAt,
    this.readAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'] ?? json['CreatedAt'];
    final readAtRaw = json['readAt'] ?? json['ReadAt'];
    return NotificationItem(
      id: json['id'] ?? json['Id'],
      title: json['title']?.toString() ?? json['Title']?.toString(),
      message: json['message']?.toString() ?? json['Message']?.toString(),
      type: json['type']?.toString() ?? json['Type']?.toString(),
      isRead: json['isRead'] ?? json['IsRead'] ?? false,
      createdAt: createdAtRaw != null
          ? DateTime.tryParse(createdAtRaw.toString())
          : null,
      readAt: readAtRaw != null
          ? DateTime.tryParse(readAtRaw.toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }
}
