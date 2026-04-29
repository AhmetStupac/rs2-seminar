import 'dart:convert';
import 'package:personaltrainer_mobile/models/payment_intent_response.dart';
import 'package:personaltrainer_mobile/models/payment_record.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';

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
    final url = "${BaseProvider.baseUrl}Payment/create-intent";
    final uri = Uri.parse(url);
    final headers = createHeaders();

    final body = jsonEncode({
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

    final body = jsonEncode({'stripePaymentIntentId': stripePaymentIntentId});

    final response = await BaseProvider.client.post(
      uri,
      headers: headers,
      body: body,
    );

    isValidResponse(response);
  }

  Future<List<PaymentRecord>> getUserPayments() async {
    final url = "${BaseProvider.baseUrl}Payment/user";
    final uri = Uri.parse(url);
    final headers = createHeaders();

    final response = await BaseProvider.client.get(uri, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return [];
      }
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.map((item) => PaymentRecord.fromJson(item)).toList();
      }
      if (data is Map && data['items'] is List) {
        final items = data['items'] as List;
        return items.map((item) => PaymentRecord.fromJson(item)).toList();
      }
      return [];
    }

    if (response.statusCode == 400 ||
        response.statusCode == 403 ||
        response.statusCode == 404) {
      final message = _extractErrorMessage(response.body);
      throw Exception(
        "API Error (${response.statusCode}): ${message.isEmpty ? response.reasonPhrase ?? 'Request failed' : message}",
      );
    }

    isValidResponse(response);
    return [];
  }

  Future<void> refundPayment(String stripePaymentIntentId) async {
    final url = "${BaseProvider.baseUrl}Payment/refund";
    final uri = Uri.parse(url);
    final headers = createHeaders();

    final body = jsonEncode({'stripePaymentIntentId': stripePaymentIntentId});

    final response = await BaseProvider.client.post(
      uri,
      headers: headers,
      body: body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    if (response.statusCode == 400 ||
        response.statusCode == 403 ||
        response.statusCode == 404) {
      final message = _extractErrorMessage(response.body);
      throw Exception(
        "API Error (${response.statusCode}): ${message.isEmpty ? response.reasonPhrase ?? 'Request failed' : message}",
      );
    }

    isValidResponse(response);
  }

  String _extractErrorMessage(String body) {
    if (body.isEmpty) return '';
    try {
      final data = jsonDecode(body);
      if (data is Map) {
        return data['message']?.toString() ??
            data['title']?.toString() ??
            data['error']?.toString() ??
            '';
      }
      return data.toString();
    } catch (_) {
      return body;
    }
  }
}
