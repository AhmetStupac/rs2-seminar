import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class MembershipAccessService {
  static const _membershipTrainerIdsKey = 'membership_trainer_ids';
  static final Set<String> _fallbackMembershipIds = <String>{};

  static Future<bool> hasMembershipForTrainer(int trainerId) async {
    final trainerIdString = trainerId.toString();

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedIds = prefs.getStringList(_membershipTrainerIdsKey) ?? [];
      return storedIds.contains(trainerIdString) ||
          _fallbackMembershipIds.contains(trainerIdString);
    } on PlatformException {
      // shared_preferences channel may be unavailable during hot-restart/dev states.
      return _fallbackMembershipIds.contains(trainerIdString);
    }
  }

  static Future<void> grantMembershipForTrainer(int trainerId) async {
    final trainerIdString = trainerId.toString();
    _fallbackMembershipIds.add(trainerIdString);

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedIds = prefs.getStringList(_membershipTrainerIdsKey) ?? [];

      if (!storedIds.contains(trainerIdString)) {
        storedIds.add(trainerIdString);
        await prefs.setStringList(_membershipTrainerIdsKey, storedIds);
      }
    } on PlatformException {
      // Keep in-memory access as fallback when plugin channel is unavailable.
    }
  }
}
