import 'package:personaltrainer_mobile/models/user.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("Users");

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }
}
