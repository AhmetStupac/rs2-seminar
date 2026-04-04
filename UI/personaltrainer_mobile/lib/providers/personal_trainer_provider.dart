import 'dart:convert';
import 'package:personaltrainer_mobile/models/personal_trainer.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';

class PersonalTrainerProvider extends BaseProvider<PersonalTrainer> {
  PersonalTrainerProvider() : super("PersonalTrainer");

  @override
  PersonalTrainer fromJson(data) {
    return PersonalTrainer.fromJson(data);
  }

  Future<PersonalTrainer?> recommend() async {
    var url = "${BaseProvider.baseUrl}PersonalTrainer/recommend";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await BaseProvider.client.get(uri, headers: headers);

    if (response.statusCode == 404) {
      return null;
    }

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to get recommendation");
    }
  }
}
