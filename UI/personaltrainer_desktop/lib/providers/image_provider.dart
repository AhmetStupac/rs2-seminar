import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart' hide Image;
import 'package:http/http.dart' as http;
import 'package:personaltrainer_mobile/providers/auth_provider.dart';

import '../models/image.dart';

class ImageProvider with ChangeNotifier {
  static String? _baseUrl;

  ImageProvider() {
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "https://localhost:7093/",
    );
  }

  Image fromJson(data) {
    return Image.fromJson(data);
  }

  Future<Image> uploadFile(
    Uint8List fileBytes,
    String fileName,
    String imageName,
    int? userId,
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
    request.fields['image'] = jsonEncode({
      'userId': userId,
      'isHeader': isHeader,
    });

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode < 299) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Upload failed: ${response.statusCode}");
    }
  }

  Map<String, String> _createHeaders() {
    String username = AuthProvider.username ?? "";
    String password = AuthProvider.password ?? "";

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    var headers = {"Authorization": basicAuth};

    return headers;
  }
}
