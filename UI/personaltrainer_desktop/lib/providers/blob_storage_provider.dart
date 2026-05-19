import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart' hide Image;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:personaltrainer_desktop/config/app_config.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart';

import '../models/image.dart';

class BlobStorageProvider with ChangeNotifier {
  final String _baseUrl = AppConfig.serverBaseUrl.endsWith('/')
      ? AppConfig.serverBaseUrl
      : '${AppConfig.serverBaseUrl}/';

  Image fromJson(data) {
    return Image.fromJson(data);
  }

  Future<Map<String, dynamic>> uploadFile(
    Uint8List fileBytes,
    String fileName,
    bool? isHeader,
  ) async {
    var url = "${_baseUrl}BlobStorage/upload";
    var uri = Uri.parse(url);
    var headers = _createHeaders();

    // Remove Content-Type from headers, multipart will set it automatically
    headers.remove('Content-Type');

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);

    // Add file with correct MIME type so the API's ContentType check passes
    final mimeType = _mimeTypeFromFileName(fileName);
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ),
    );

    // Add image name as string field
    request.fields['image'] = jsonEncode({'isHeader': isHeader});

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);


    if (response.statusCode < 299) {
      var data = jsonDecode(response.body);

      // Vrati mapu sa podacima koje backend Ĺˇalje
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
      final response = await http.get(Uri.parse(imageUrl));


      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  String _mimeTypeFromFileName(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      default:
        return 'application/octet-stream';
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

