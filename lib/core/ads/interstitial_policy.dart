/// When a full-screen ad may be shown (CLAUDE.md §8). Only ever checked
/// when leaving a round summary.
///
/// Deliberately rare: never in the first session, at most once per session,
/// at least [minRoundsBetween] completed rounds and [minInterval] apart.
class InterstitialPolicy {
  const new({
    this.minRoundsBetween = 5,
    this.minInterval = const Duration(minutes: 10),
    this.maxPerSession = 1,
  });

  final int minRoundsBetween;
  final Duration minInterval;
  final int maxPerSession;

  bool allows({
    required int session,
    required int roundsCompleted,
    required int roundsAtLastAd,
    required DateTime? lastAdAt,
    required int shownThisSession,
    required DateTime now,
  }) =>
      session > 1 &&
      shownThisSession < maxPerSession &&
      roundsCompleted - roundsAtLastAd >= minRoundsBetween &&
      (lastAdAt == null || now.difference(lastAdAt) >= minInterval);
}
