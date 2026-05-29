import 'dart:convert';
import 'package:personaltrainer_mobile/models/group_training_session.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';

class GroupTrainingSessionProvider extends BaseProvider<GroupTrainingSession> {
  GroupTrainingSessionProvider() : super("GroupTrainingSession");

  @override
  GroupTrainingSession fromJson(data) {
    return GroupTrainingSession.fromJson(data);
  }

  Future<GroupTrainingSession> join(int sessionId) async {
    final url = "${BaseProvider.baseUrl}GroupTrainingSession/$sessionId/join";
    final uri = Uri.parse(url);
    final headers = createHeaders();

    final response = await BaseProvider.client.post(uri, headers: headers);

    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to join group training session");
    }
  }

  Future<bool> leave(int sessionId) async {
    final url = "${BaseProvider.baseUrl}GroupTrainingSession/$sessionId/leave";
    final uri = Uri.parse(url);
    final headers = createHeaders();

    final response = await BaseProvider.client.delete(uri, headers: headers);

    if (isValidResponse(response)) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception("Failed to leave group training session");
    }
  }

  Future<void> deleteSession(int id) async {
    final url = "${BaseProvider.baseUrl}GroupTrainingSession/$id";
    final uri = Uri.parse(url);
    final headers = createHeaders();

    final response = await BaseProvider.client.delete(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw Exception("Failed to delete group training session");
    }
  }
}
