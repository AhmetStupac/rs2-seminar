import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personaltrainer_mobile/models/user.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("Users");

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }

  Future<User?> getCurrentUser() async {
    if (AuthProvider.userId == null) return null;
    var url = "${BaseProvider.baseUrl}Users/${AuthProvider.userId}";
    var uri = Uri.parse(url);
    var headers = {
      "Content-Type": "application/json",
    };
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return User.fromJson(data);
    }
    return null;
  }
}
