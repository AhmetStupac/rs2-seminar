import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart' hide Image;
import 'package:http/http.dart' as http;
import 'package:personaltrainer_mobile/providers/auth_provider.dart';

import '../models/image.dart';

class BlobStorageProvider with ChangeNotifier {
  static String? _baseUrl;

  BlobStorageProvider() {
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "https://localhost:7093/",
    );
  }

  Image fromJson(data) {
    return Image.fromJson(data);
  }

  Future<Map<String, dynamic>> uploadFile(
    Uint8List fileBytes,
    String fileName,
    bool? isHeader,
  ) async {
    var url = "${_baseUrl}BlobStorage/upload";
    print("Uploading to: $url");
    var uri = Uri.parse(url);
    var headers = _createHeaders();

    // Remove Content-Type from headers, multipart will set it automatically
    headers.remove('Content-Type');

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);

    // Add file
    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
    );

    // Add image name as string field
    request.fields['image'] = jsonEncode({'isHeader': isHeader});

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode < 299) {
      var data = jsonDecode(response.body);

      // Vrati mapu sa podacima koje backend šalje
      return {
        'imageId': data['imageId'],
        'fileUrl': data['fileUrl'],
        'blobName': data['blobName'],
      };
    } else {
      throw Exception(
        "Upload failed: ${response.statusCode} - ${response.body}",
      );
    }
  }

  // Metoda za preuzimanje slike sa URL-a kao bytes
  Future<Uint8List?> downloadImageBytes(String imageUrl) async {
    try {
      print('📥 BlobStorageProvider: Downloading image from: $imageUrl');
      final response = await http.get(Uri.parse(imageUrl));

      print('📥 BlobStorageProvider: Response status: ${response.statusCode}');
      print(
        '📥 BlobStorageProvider: Content-Type: ${response.headers['content-type']}',
      );
      print(
        '📥 BlobStorageProvider: Body length: ${response.bodyBytes.length}',
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('❌ Failed to download image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error downloading image: $e');
      return null;
    }
  }

  Map<String, String> _createHeaders() {
    String token = AuthProvider.token ?? "";

    var headers = <String, String>{};

    if (token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }
}
