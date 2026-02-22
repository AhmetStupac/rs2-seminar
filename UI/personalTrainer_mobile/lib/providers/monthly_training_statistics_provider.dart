import 'dart:convert';
import 'package:personaltrainer_mobile/models/monthly_training_statistics.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';

class MonthlyTrainingStatisticsProvider
    extends BaseProvider<MonthlyTrainingStatistics> {
  MonthlyTrainingStatisticsProvider() : super("MonthlyTrainingStatistics");

  @override
  MonthlyTrainingStatistics fromJson(data) {
    return MonthlyTrainingStatistics.fromJson(data);
  }

  // Get current year statistics for authenticated user
  Future<List<MonthlyTrainingStatistics>> getMyStatistics() async {
    var url = "${BaseProvider.baseUrl}MonthlyTrainingStatistics/my-statistics";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    print("🔍 GET Request to: $url");
    print("🔍 Headers: ${headers.keys.join(', ')}");

    var response = await BaseProvider.client.get(uri, headers: headers);

    print("🔍 Response status: ${response.statusCode}");
    print("🔍 Response body: ${response.body}");

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body) as List;
      return data.map((item) => fromJson(item)).toList();
    } else {
      throw Exception("Failed to get statistics");
    }
  }

  // Get statistics for a specific year
  Future<List<MonthlyTrainingStatistics>> getMyStatisticsByYear(
    int year,
  ) async {
    var url =
        "${BaseProvider.baseUrl}MonthlyTrainingStatistics/my-statistics/year/$year";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    print("🔍 GET Request to: $url");
    print("🔍 Headers: ${headers.keys.join(', ')}");

    var response = await BaseProvider.client.get(uri, headers: headers);

    print("🔍 Response status: ${response.statusCode}");
    print("🔍 Response body: ${response.body}");

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body) as List;
      return data.map((item) => fromJson(item)).toList();
    } else {
      throw Exception("Failed to get statistics for year $year");
    }
  }

  // Update monthly comment
  Future<MonthlyTrainingStatistics> updateMonthlyComment(
    int userId,
    MonthlyCommentUpsertRequest request,
  ) async {
    var url =
        "${BaseProvider.baseUrl}MonthlyTrainingStatistics/user/$userId/comment";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request.toJson());
    var response = await BaseProvider.client.put(
      uri,
      headers: headers,
      body: jsonRequest,
    );

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to update comment");
    }
  }
}
