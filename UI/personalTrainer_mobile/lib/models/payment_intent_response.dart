class PaymentIntentResponse {
  final String clientSecret;
  final int paymentRecordId;
  final int amountInCents;

  PaymentIntentResponse({
    required this.clientSecret,
    required this.paymentRecordId,
    required this.amountInCents,
  });

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentIntentResponse(
      clientSecret: json['clientSecret'] as String,
      paymentRecordId: json['paymentRecordId'] as int,
      amountInCents: json['amountInCents'] as int,
    );
  }
}
