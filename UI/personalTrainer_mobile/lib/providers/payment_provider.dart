import 'dart:convert';
import 'package:personaltrainer_mobile/models/payment_intent_response.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';

class PaymentProvider extends BaseProvider<dynamic> {
  PaymentProvider() : super("Payment");

  @override
  dynamic fromJson(data) => data;

  /// Creates a Stripe PaymentIntent via the backend.
  /// [itemType]: 0 = TrainingPlan, 1 = NutritionPlan, 2 = Membership
  Future<PaymentIntentResponse> createPaymentIntent({
    required int userId,
    required int itemType,
    int? itemId,
    int? customAmountInCents,
  }) async {
    final url = "${BaseProvider.baseUrl}Payment/create-intent";
    final uri = Uri.parse(url);
    final headers = createHeaders();

    final body = jsonEncode({
      'userId': userId,
      'itemType': itemType,
      if (itemId != null) 'itemId': itemId,
      if (customAmountInCents != null)
        'customAmountInCents': customAmountInCents,
    });

    final response = await BaseProvider.client.post(
      uri,
      headers: headers,
      body: body,
    );

    if (isValidResponse(response)) {
      final data = jsonDecode(response.body);
      return PaymentIntentResponse.fromJson(data);
    } else {
      throw Exception("Failed to create payment intent");
    }
  }

  /// Confirms the payment on the backend after Stripe confirms it on the client.
  Future<void> confirmPayment(String stripePaymentIntentId) async {
    final url = "${BaseProvider.baseUrl}Payment/confirm";
    final uri = Uri.parse(url);
    final headers = createHeaders();

    final body = jsonEncode({
      'stripePaymentIntentId': stripePaymentIntentId,
    });

    final response = await BaseProvider.client.post(
      uri,
      headers: headers,
      body: body,
    );

    isValidResponse(response);
  }
}
