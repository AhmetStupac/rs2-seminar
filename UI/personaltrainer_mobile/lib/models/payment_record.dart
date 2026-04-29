class PaymentRecord {
  final int? id;
  final int? itemType;
  final int? itemId;
  final String? itemName;
  final int? amountInCents;
  final String? status;
  final String? stripePaymentIntentId;
  final DateTime? createdAt;

  PaymentRecord({
    this.id,
    this.itemType,
    this.itemId,
    this.itemName,
    this.amountInCents,
    this.status,
    this.stripePaymentIntentId,
    this.createdAt,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: _parseInt(json['id']),
      itemType: _parseInt(json['itemType']),
      itemId: _parseInt(json['itemId']),
      itemName: json['itemName']?.toString() ?? json['name']?.toString(),
      amountInCents: _parseInt(
        json['amountInCents'] ?? json['amount'] ?? json['amountInEuroCents'],
      ),
      status: _parseStatus(
        json['status'] ?? json['paymentStatus'] ?? json['statusDisplay'],
      ),
      stripePaymentIntentId:
          json['stripePaymentIntentId']?.toString() ??
          json['paymentIntentId']?.toString(),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _parseStatus(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
