// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingSession _$TrainingSessionFromJson(Map<String, dynamic> json) =>
    TrainingSession(
      id: (json['id'] as num?)?.toInt(),
      clientId: (json['clientId'] as num?)?.toInt(),
      clientName: json['clientName'] as String?,
      personalTrainerId: (json['personalTrainerId'] as num?)?.toInt(),
      trainerName: json['trainerName'] as String?,
      gymId: (json['gymId'] as num?)?.toInt(),
      gymName: json['gymName'] as String?,
      scheduledDateTime: json['scheduledDateTime'] == null
          ? null
          : DateTime.parse(json['scheduledDateTime'] as String),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      statusDisplay: json['statusDisplay'] as String?,
      notes: json['notes'] as String?,
      trainerNotes: json['trainerNotes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      approvedByUserId: (json['approvedByUserId'] as num?)?.toInt(),
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      cancelledByUserId: (json['cancelledByUserId'] as num?)?.toInt(),
      cancellationReason: json['cancellationReason'] as String?,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      completedByUserId: (json['completedByUserId'] as num?)?.toInt(),
      noShowAt: json['noShowAt'] == null
          ? null
          : DateTime.parse(json['noShowAt'] as String),
      noShowByUserId: (json['noShowByUserId'] as num?)?.toInt(),
      canEdit: json['canEdit'] as bool?,
      canCancel: json['canCancel'] as bool?,
    );

Map<String, dynamic> _$TrainingSessionToJson(TrainingSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'clientName': instance.clientName,
      'personalTrainerId': instance.personalTrainerId,
      'trainerName': instance.trainerName,
      'gymId': instance.gymId,
      'gymName': instance.gymName,
      'scheduledDateTime': instance.scheduledDateTime?.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'status': instance.status,
      'statusDisplay': instance.statusDisplay,
      'notes': instance.notes,
      'trainerNotes': instance.trainerNotes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'approvedByUserId': instance.approvedByUserId,
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'cancelledByUserId': instance.cancelledByUserId,
      'cancellationReason': instance.cancellationReason,
      'completedAt': instance.completedAt?.toIso8601String(),
      'completedByUserId': instance.completedByUserId,
      'noShowAt': instance.noShowAt?.toIso8601String(),
      'noShowByUserId': instance.noShowByUserId,
      'canEdit': instance.canEdit,
      'canCancel': instance.canCancel,
    };

TrainingSessionUpsertRequest _$TrainingSessionUpsertRequestFromJson(
  Map<String, dynamic> json,
) => TrainingSessionUpsertRequest(
  personalTrainerId: (json['personalTrainerId'] as num?)?.toInt(),
  gymId: (json['gymId'] as num?)?.toInt(),
  scheduledDateTime: json['scheduledDateTime'] == null
      ? null
      : DateTime.parse(json['scheduledDateTime'] as String),
  durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  status: (json['status'] as num?)?.toInt(),
  trainerNotes: json['trainerNotes'] as String?,
);

Map<String, dynamic> _$TrainingSessionUpsertRequestToJson(
  TrainingSessionUpsertRequest instance,
) => <String, dynamic>{
  'personalTrainerId': instance.personalTrainerId,
  'gymId': instance.gymId,
  'scheduledDateTime': instance.scheduledDateTime?.toIso8601String(),
  'durationMinutes': instance.durationMinutes,
  'notes': instance.notes,
  'status': instance.status,
  'trainerNotes': instance.trainerNotes,
};

TrainingSessionCancelRequest _$TrainingSessionCancelRequestFromJson(
  Map<String, dynamic> json,
) => TrainingSessionCancelRequest(
  cancellationReason: json['cancellationReason'] as String?,
);

Map<String, dynamic> _$TrainingSessionCancelRequestToJson(
  TrainingSessionCancelRequest instance,
) => <String, dynamic>{'cancellationReason': instance.cancellationReason};
