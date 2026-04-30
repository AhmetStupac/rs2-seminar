class Membership {
  final int id;
  final int clientUserId;
  final String? clientFullName;
  final int personalTrainerId;
  final String? trainerFullName;
  final int? paymentId;
  final DateTime startDate;
  final DateTime expiryDate;
  final bool isActive;
  final bool isRevoked;
  final int daysRemaining;
  final DateTime createdAt;

  const Membership({
    required this.id,
    required this.clientUserId,
    this.clientFullName,
    required this.personalTrainerId,
    this.trainerFullName,
    this.paymentId,
    required this.startDate,
    required this.expiryDate,
    required this.isActive,
    required this.isRevoked,
    required this.daysRemaining,
    required this.createdAt,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    T? _pick<T>(String camel, String pascal) {
      final v = json[camel] ?? json[pascal];
      return v is T ? v : null;
    }

    DateTime _parseDate(String camel, String pascal) {
      final raw = json[camel]?.toString() ?? json[pascal]?.toString() ?? '';
      return DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    return Membership(
      id: (_pick<num>('id', 'Id')?.toInt()) ?? 0,
      clientUserId: (_pick<num>('clientUserId', 'ClientUserId')?.toInt()) ?? 0,
      clientFullName: _pick<String>('clientFullName', 'ClientFullName'),
      personalTrainerId:
          (_pick<num>('personalTrainerId', 'PersonalTrainerId')?.toInt()) ?? 0,
      trainerFullName: _pick<String>('trainerFullName', 'TrainerFullName'),
      paymentId: _pick<num>('paymentId', 'PaymentId')?.toInt(),
      startDate: _parseDate('startDate', 'StartDate'),
      expiryDate: _parseDate('expiryDate', 'ExpiryDate'),
      isActive: (_pick<bool>('isActive', 'IsActive')) ?? false,
      isRevoked: (_pick<bool>('isRevoked', 'IsRevoked')) ?? false,
      daysRemaining:
          (_pick<num>('daysRemaining', 'DaysRemaining')?.toInt()) ?? 0,
      createdAt: _parseDate('createdAt', 'CreatedAt'),
    );
  }
}
