import 'dart:convert';

import 'package:personaltrainer_mobile/models/membership.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';

class MembershipProvider extends BaseProvider<dynamic> {
  MembershipProvider() : super('Membership');

  @override
  dynamic fromJson(data) => data;

  /// Returns all memberships (active + expired) for the current user.
  Future<List<Membership>> getMyMemberships() async {
    final uri = Uri.parse('${BaseProvider.baseUrl}Membership/my');
    final response = await BaseProvider.client.get(
      uri,
      headers: createHeaders(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(Membership.fromJson)
            .toList();
      }
      if (data is Map && (data['items'] ?? data['Items']) is List) {
        final items = (data['items'] ?? data['Items']) as List;
        return items
            .whereType<Map<String, dynamic>>()
            .map(Membership.fromJson)
            .toList();
      }
      return [];
    }

    final msg = _extractError(response.body);
    throw Exception('API Error (${response.statusCode}): $msg');
  }

  /// Returns true if the current user has an active membership with [trainerId].
  Future<bool> hasActiveMembership(int trainerId) async {
    final uri = Uri.parse('${BaseProvider.baseUrl}Membership/active/$trainerId');
    final response = await BaseProvider.client.get(
      uri,
      headers: createHeaders(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return false;
      final data = jsonDecode(response.body);
      if (data is Map) {
        final val = data['isActive'] ?? data['IsActive'];
        return val == true;
      }
      if (data is bool) return data;
      return false;
    }

    if (response.statusCode == 404) return false;

    final msg = _extractError(response.body);
    throw Exception('API Error (${response.statusCode}): $msg');
  }

  /// Returns the number of active clients the trainer currently has.
  Future<int> getActiveClientCount(int trainerId) async {
    final uri = Uri.parse(
      '${BaseProvider.baseUrl}Membership/trainer/$trainerId/active-count',
    );
    final response = await BaseProvider.client.get(
      uri,
      headers: createHeaders(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return 0;
      final data = jsonDecode(response.body);
      if (data is Map) {
        final val = data['activeClientCount'] ?? data['ActiveClientCount'];
        return (val as num?)?.toInt() ?? 0;
      }
      return 0;
    }

    if (response.statusCode == 404) return 0;

    final msg = _extractError(response.body);
    throw Exception('API Error (${response.statusCode}): $msg');
  }

  String _extractError(String body) {
    if (body.isEmpty) return 'Unknown error';
    try {
      final data = jsonDecode(body);
      if (data is Map) {
        return data['message']?.toString() ??
            data['title']?.toString() ??
            data['error']?.toString() ??
            body;
      }
      return body;
    } catch (_) {
      return body;
    }
  }
}
