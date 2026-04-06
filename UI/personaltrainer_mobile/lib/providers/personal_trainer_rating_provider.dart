import 'dart:convert';
import 'package:personaltrainer_mobile/models/personal_trainer_rating.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';

class PersonalTrainerRatingProvider extends BaseProvider<PersonalTrainerRatingResponse> {
  PersonalTrainerRatingProvider() : super("PersonalTrainerRating");

  @override
  PersonalTrainerRatingResponse fromJson(data) {
    return PersonalTrainerRatingResponse.fromJson(data);
  }

  // Get current user's rating for a specific trainer
  Future<PersonalTrainerRatingResponse?> getMyRating(int personalTrainerId) async {
    var url = "${BaseProvider.baseUrl}PersonalTrainerRating/my-rating/$personalTrainerId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    
    var response = await BaseProvider.client.get(uri, headers: headers);


    if (response.statusCode == 404) {
      // No rating found
      return null;
    }

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return PersonalTrainerRatingResponse.fromJson(data);
    } else {
      throw Exception("Failed to get rating");
    }
  }

  // Get all ratings for a specific trainer
  Future<List<PersonalTrainerRatingResponse>> getRatingsForTrainer(int personalTrainerId) async {
    var url = "${BaseProvider.baseUrl}PersonalTrainerRating/trainer/$personalTrainerId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    
    var response = await BaseProvider.client.get(uri, headers: headers);


    if (isValidResponse(response)) {
      var data = jsonDecode(response.body) as List;
      return data.map((item) => PersonalTrainerRatingResponse.fromJson(item)).toList();
    } else {
      throw Exception("Failed to get ratings");
    }
  }

  // Get rating statistics for a trainer
  Future<PersonalTrainerRatingStats> getTrainerRatingStats(int personalTrainerId) async {
    var url = "${BaseProvider.baseUrl}PersonalTrainerRating/trainer/$personalTrainerId/stats";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    
    var response = await BaseProvider.client.get(uri, headers: headers);


    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return PersonalTrainerRatingStats.fromJson(data);
    } else {
      throw Exception("Failed to get rating statistics");
    }
  }

  // Create a new rating
  Future<PersonalTrainerRatingResponse> createRating(PersonalTrainerRatingUpsertRequest request) async {
    var url = "${BaseProvider.baseUrl}PersonalTrainerRating";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request.toJson());
    
    var response = await BaseProvider.client.post(uri, headers: headers, body: jsonRequest);


    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return PersonalTrainerRatingResponse.fromJson(data);
    } else {
      var errorMessage = "Failed to create rating";
      if (response.statusCode == 400) {
        try {
          var errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}
      }
      throw Exception(errorMessage);
    }
  }

  // Update existing rating
  Future<PersonalTrainerRatingResponse?> updateRating(int ratingId, PersonalTrainerRatingUpsertRequest request) async {
    var url = "${BaseProvider.baseUrl}PersonalTrainerRating/$ratingId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request.toJson());
    
    var response = await BaseProvider.client.put(uri, headers: headers, body: jsonRequest);


    if (response.statusCode == 404) {
      return null;
    }

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return PersonalTrainerRatingResponse.fromJson(data);
    } else {
      throw Exception("Failed to update rating");
    }
  }

  // Delete rating
  Future<bool> deleteRating(int ratingId) async {
    var url = "${BaseProvider.baseUrl}PersonalTrainerRating/$ratingId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    
    var response = await BaseProvider.client.delete(uri, headers: headers);


    if (response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 404) {
      return false;
    } else {
      throw Exception("Failed to delete rating");
    }
  }
}
