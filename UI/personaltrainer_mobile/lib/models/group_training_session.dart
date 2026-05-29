class GroupTrainingSessionParticipant {
  final int userId;
  final String userName;
  final DateTime joinedAt;

  GroupTrainingSessionParticipant({
    required this.userId,
    required this.userName,
    required this.joinedAt,
  });

  factory GroupTrainingSessionParticipant.fromJson(Map<String, dynamic> json) {
    return GroupTrainingSessionParticipant(
      userId: (json['userId'] as num).toInt(),
      userName: json['userName'] as String? ?? '',
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }
}

class GroupTrainingSession {
  final int id;
  final String name;
  final String trainingType;
  final int kcalBurned;
  final int durationMinutes;
  final String place;
  final String? notes;
  final int creatorId;
  final String creatorName;
  final DateTime createdAt;
  final int participantCount;
  final List<GroupTrainingSessionParticipant> participants;

  GroupTrainingSession({
    required this.id,
    required this.name,
    required this.trainingType,
    required this.kcalBurned,
    required this.durationMinutes,
    required this.place,
    this.notes,
    required this.creatorId,
    required this.creatorName,
    required this.createdAt,
    required this.participantCount,
    required this.participants,
  });

  factory GroupTrainingSession.fromJson(Map<String, dynamic> json) {
    final participantsList = (json['participants'] as List<dynamic>? ?? [])
        .map((p) => GroupTrainingSessionParticipant.fromJson(
              p as Map<String, dynamic>,
            ))
        .toList();

    return GroupTrainingSession(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      trainingType: json['trainingType'] as String? ?? '',
      kcalBurned: (json['kcalBurned'] as num?)?.toInt() ?? 0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      place: json['place'] as String? ?? '',
      notes: json['notes'] as String?,
      creatorId: (json['creatorId'] as num).toInt(),
      creatorName: json['creatorName'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
      participants: participantsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'trainingType': trainingType,
        'kcalBurned': kcalBurned,
        'durationMinutes': durationMinutes,
        'place': place,
        if (notes != null) 'notes': notes,
      };
}
