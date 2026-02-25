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
    print('🔍 Interceptor: ${request.method} ${request.url}');
    
    final response = await _client.send(request);

    // Provera bana - 403 Forbidden
    if (response.statusCode == 403) {
      print('⛔ Interceptor: Detected 403 - User might be banned');
      
      // Pročitaj response body
      final responseBody = await response.stream.bytesToString();
      
      try {
        final jsonResponse = jsonDecode(responseBody);
        
        // Proveri da li je poruka o banu (a ne neka druga 403 greška)
        final message = jsonResponse['message']?.toString().toLowerCase() ?? '';
        
        if (message.contains('banovan') || message.contains('banned')) {
          print('🚫 User is banned! Redirecting to BannedScreen...');
          
          // Prebaci na Ban screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => BannedScreen(
                  reason: jsonResponse['reason'] ?? 'Nije naveden razlog',
                  bannedAt: jsonResponse['bannedAt'] != null 
                      ? DateTime.parse(jsonResponse['bannedAt']) 
                      : null,
                  expiresAt: jsonResponse['expiresAt'] != null 
                      ? DateTime.parse(jsonResponse['expiresAt']) 
                      : null,
                  isPermanent: jsonResponse['isPermanent'] ?? true,
                ),
              ),
              (route) => false, // Ukloni sve prethodne route
            );
          });
        }
      } catch (e) {
        print('❌ Error parsing ban response: $e');
      }

      // Vrati response sa novim stream-om
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