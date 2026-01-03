import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:personaltrainer_mobile/providers/auth_provider.dart';

class ExerciseProvider {
  ExerciseProvider();

  Future<dynamic> get() async {
    var url = "https://localhost:7093/api/Exercise";
    var uri = Uri.parse(url);

    var response = await http.get(uri, headers: createHeaders());

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Unknown exception");
    }
  }

  bool isValidResponse(http.Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else
      throw Exception("Something bad happenend, please try again");
  }

  Map<String, String> createHeaders() {
    String username = AuthProvider.username!;
    String password = AuthProvider.password!;

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };

    return headers;
  }
}
