import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personaltrainer_desktop/models/training_session.dart';
import 'package:personaltrainer_desktop/providers/base_provider.dart';

class TrainingSessionProvider extends BaseProvider<TrainingSession> {
  TrainingSessionProvider() : super("TrainingSession");

  @override
  TrainingSession fromJson(data) {
    return TrainingSession.fromJson(data);
  }

  // Confirm a training session (trainer only)
  Future<TrainingSession> confirm(int id) async {
    var url = "${BaseProvider.baseUrl}TrainingSession/$id/confirm";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to confirm training session");
    }
  }

  // Cancel a training session
  Future<TrainingSession> cancel(
    int id,
    TrainingSessionCancelRequest request,
  ) async {
    var url = "${BaseProvider.baseUrl}TrainingSession/$id/cancel";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request.toJson());
    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to cancel training session");
    }
  }

  // Get available time slots for a trainer
  Future<List<DateTime>> getAvailableSlots(
    int trainerId,
    DateTime date, {
    int durationMinutes = 60,
  }) async {
    var url =
        "${BaseProvider.baseUrl}TrainingSession/availability/$trainerId?date=${date.toIso8601String()}&durationMinutes=$durationMinutes";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body) as List;
      return data.map((item) => DateTime.parse(item)).toList();
    } else {
      throw Exception("Failed to get available slots");
    }
  }

  // Check if a trainer is available at a specific time
  Future<bool> checkAvailability(
    int trainerId,
    DateTime scheduledDateTime,
    int durationMinutes,
  ) async {
    var url =
        "${BaseProvider.baseUrl}TrainingSession/check-availability?trainerId=$trainerId&scheduledDateTime=${scheduledDateTime.toIso8601String()}&durationMinutes=$durationMinutes";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception("Failed to check availability");
    }
  }
}
