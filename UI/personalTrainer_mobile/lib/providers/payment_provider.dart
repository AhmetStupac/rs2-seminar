import 'dart:convert';
import 'package:personaltrainer_mobile/models/payment_intent_response.dart';
import 'package:personaltrainer_mobile/models/payment_record.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';
import 'package:personaltrainer_mobile/utils/api_error.dart';

class PaymentProvider extends BaseProvider<dynamic> {
  PaymentProvider() : super("Payment");

  @override
  dynamic fromJson(data) => data;

  /// Creates a Stripe PaymentIntent via the backend.
  /// [itemType]: 0 = TrainingPlan, 1 = NutritionPlan, 2 = Membership
  Future<PaymentIntentResponse> createPaymentIntent({
    required int itemType,
    int? itemId,
    int? customAmountInCents,
  }) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Payment/create-intent");
    final response = await BaseProvider.client.post(
      uri,
      headers: createHeaders(),
      body: jsonEncode({
        'itemType': itemType,
        if (itemId != null) 'itemId': itemId,
        if (customAmountInCents != null) 'customAmountInCents': customAmountInCents,
      }),
    );

    if (isValidResponse(response)) {
      return PaymentIntentResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception("Failed to create payment intent");
  }

  /// Confirms the payment on the backend after Stripe confirms it on the client.
  Future<void> confirmPayment(String stripePaymentIntentId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Payment/confirm");
    final response = await BaseProvider.client.post(
      uri,
      headers: createHeaders(),
      body: jsonEncode({'stripePaymentIntentId': stripePaymentIntentId}),
    );
    isValidResponse(response);
  }

  Future<List<PaymentRecord>> getUserPayments({int page = 0, int pageSize = 50}) async {
    final uri = Uri.parse(
      "${BaseProvider.baseUrl}Payment/user?page=$page&pageSize=$pageSize",
    );
    final response = await BaseProvider.client.get(uri, headers: createHeaders());

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return [];
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.map((item) => PaymentRecord.fromJson(item)).toList();
      }
      if (data is Map && data['items'] is List) {
        return (data['items'] as List)
            .map((item) => PaymentRecord.fromJson(item))
            .toList();
      }
      return [];
    }

    // Delegates to the central parser — throws with the backend message.
    isValidResponse(response);
    return [];
  }

  Future<void> refundPayment(String stripePaymentIntentId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Payment/refund-request");
    final response = await BaseProvider.client.post(
      uri,
      headers: createHeaders(),
      body: jsonEncode({'stripePaymentIntentId': stripePaymentIntentId}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) return;

    // Use the central parser so the backend message reaches the UI.
    throw Exception(
      ApiError.fromBody(response.body, statusCode: response.statusCode),
    );
  }
}
