import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

// TODO: Create BannedScreen
// import 'package:personaltrainer_mobile/screens/banned_screen.dart';

class AuthInterceptor extends http.BaseClient {
  final http.Client _client = IOClient(
    HttpClient()..badCertificateCallback = (cert, host, port) => true,
  );
  final GlobalKey<NavigatorState> navigatorKey;

  AuthInterceptor({required this.navigatorKey});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    
    final response = await _client.send(request);

    // Provera bana - 403 Forbidden
    if (response.statusCode == 403) {
      
      // Pročitaj response body
      final responseBody = await response.stream.bytesToString();
      
      try {
        final jsonResponse = jsonDecode(responseBody);
        
        // Proveri da li je poruka o banu (a ne neka druga 403 greška)
        final message = jsonResponse['message']?.toString().toLowerCase() ?? '';
        
        if (message.contains('banovan') || message.contains('banned')) {
          
          // TODO: Redirect to BannedScreen when implemented
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.block, size: 100, color: Colors.red),
                        SizedBox(height: 20),
                        Text(
                          'Account Banned',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text('Your account has been banned.'),
                      ],
                    ),
                  ),
                ),
              ),
              (route) => false,
            );
          });
        }
      } catch (e) {
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