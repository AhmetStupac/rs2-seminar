import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:personaltrainer_desktop/screens/banned_screen.dart';

class AuthInterceptor extends http.BaseClient {
  final http.Client _client = http.Client();
  final GlobalKey<NavigatorState> navigatorKey;

  AuthInterceptor({required this.navigatorKey});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _client.send(request);

    // Ban check - 403 Forbidden
    if (response.statusCode == 403) {
      // Read response body
      final responseBody = await response.stream.bytesToString();

      try {
        final jsonResponse = jsonDecode(responseBody);

        // Check whether the message is about a ban (not another 403 error).
        final message = jsonResponse['message']?.toString().toLowerCase() ?? '';

        if (message.contains('banovan') || message.contains('banned')) {
          // Redirect to banned screen.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => BannedScreen(
                  reason: jsonResponse['reason'] ?? 'No reason provided',
                  bannedAt: jsonResponse['bannedAt'] != null
                      ? DateTime.parse(jsonResponse['bannedAt'])
                      : null,
                  expiresAt: jsonResponse['expiresAt'] != null
                      ? DateTime.parse(jsonResponse['expiresAt'])
                      : null,
                  isPermanent: jsonResponse['isPermanent'] ?? true,
                ),
              ),
              (route) => false,
            );
          });
        }
      } catch (e) {}

      // Return response with a new stream.
      return http.StreamedResponse(
        Stream.value(utf8.encode(responseBody)),
        response.statusCode,
        headers: response.headers,
        request: response.request,
        reasonPhrase: response.reasonPhrase,
        contentLength: responseBody.length,
      );
    }

    return response;
  }
}
