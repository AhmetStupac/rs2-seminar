import 'package:json_annotation/json_annotation.dart';

part 'training_session.g.dart';

@JsonSerializable()
class TrainingSession {
  int? id;
  int? clientId;
  String? clientName;
  int? personalTrainerId;
  String? trainerName;
  int? gymId;
  String? gymName;
  DateTime? scheduledDateTime;
  int? durationMinutes;
  int? status;
  String? statusDisplay;
  String? notes;
  String? trainerNotes;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? cancelledAt;
  String? cancellationReason;
  bool? canEdit;
  bool? canCancel;

  TrainingSession({
    this.id,
    this.clientId,
    this.clientName,
    this.personalTrainerId,
    this.trainerName,
    this.gymId,
    this.gymName,
    this.scheduledDateTime,
    this.durationMinutes,
    this.status,
    this.statusDisplay,
    this.notes,
    this.trainerNotes,
    this.createdAt,
    this.updatedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.canEdit,
    this.canCancel,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) =>
      _$TrainingSessionFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingSessionToJson(this);

  // Helper getters
  DateTime get endDateTime =>
      scheduledDateTime?.add(Duration(minutes: durationMinutes ?? 60)) ??
      DateTime.now();

  bool get isPending => status == 0;
  bool get isConfirmed => status == 1;
  bool get isCompleted => status == 2;
  bool get isCancelled => status == 3;
  bool get isNoShow => status == 4;
}

@JsonSerializable()
class TrainingSessionUpsertRequest {
  int? personalTrainerId;
  int? gymId;
  DateTime? scheduledDateTime;
  int? durationMinutes;
  String? notes;
  int? status;
  String? trainerNotes;

  TrainingSessionUpsertRequest({
    this.personalTrainerId,
    this.gymId,
    this.scheduledDateTime,
    this.durationMinutes,
    this.notes,
    this.status,
    this.trainerNotes,
  });

  factory TrainingSessionUpsertRequest.fromJson(Map<String, dynamic> json) =>
      _$TrainingSessionUpsertRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingSessionUpsertRequestToJson(this);
}

@JsonSerializable()
class TrainingSessionCancelRequest {
  String? cancellationReason;

  TrainingSessionCancelRequest({this.cancellationReason});

  factory TrainingSessionCancelRequest.fromJson(Map<String, dynamic> json) =>
      _$TrainingSessionCancelRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingSessionCancelRequestToJson(this);
}
