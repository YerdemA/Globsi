import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globsi/core/data/preferences.dart';
import 'package:globsi/core/stats/practice_stats.dart';

/// Practice statistics, kept on the device only (one JSON value in
/// shared_preferences).
final statsProvider = NotifierProvider<StatsService, PracticeStats>(
  StatsService.new,
);

class StatsService extends Notifier<PracticeStats> {
  static const storageKey = 'stats';

  @override
  PracticeStats build() {
    final raw = ref.read(sharedPreferencesProvider).getString(storageKey);
    if (raw == null) return const PracticeStats();
    try {
      return PracticeStats.fromJson(jsonDecode(raw));
    } on FormatException {
      return const PracticeStats();
    }
  }

  /// Adds a finished round and returns the best score for its mode and
  /// filter before this round (to show "new best").
  Future<BestScore?> recordRound({
    required String mode,
    required String filterKey,
    required List<AnswerResult> results,
  }) async {
    final previousBest = state.bestScore(mode, filterKey);
    state = state.recordRound(
      mode: mode,
      filterKey: filterKey,
      results: results,
    );
    await _save();
    return previousBest;
  }

  Future<void> reset() async {
    state = const PracticeStats();
    await ref.read(sharedPreferencesProvider).remove(storageKey);
  }

  Future<void> _save() => ref
      .read(sharedPreferencesProvider)
      .setString(storageKey, jsonEncode(state.toJson()));
}
