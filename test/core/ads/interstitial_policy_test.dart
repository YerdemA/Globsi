import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/core/ads/ad_history.dart';
import 'package:globsi/core/ads/interstitial_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const policy = InterstitialPolicy();
  final now = DateTime(2026, 10, 29, 12);

  bool allows({
    int session = 2,
    int rounds = 5,
    int roundsAtLastAd = 0,
    DateTime? lastAdAt,
    int shownThisSession = 0,
  }) => policy.allows(
    session: session,
    roundsCompleted: rounds,
    roundsAtLastAd: roundsAtLastAd,
    lastAdAt: lastAdAt,
    shownThisSession: shownThisSession,
    now: now,
  );

  group('InterstitialPolicy', () {
    test('allows an ad after 5 rounds in a later session', () {
      expect(allows(), isTrue);
    });

    test('never in the first session', () {
      expect(allows(session: 1, rounds: 50), isFalse);
    });

    test('needs 5 completed rounds since the last ad', () {
      expect(allows(rounds: 4), isFalse);
      expect(allows(rounds: 9, roundsAtLastAd: 5), isFalse);
      expect(
        allows(
          rounds: 10,
          roundsAtLastAd: 5,
          lastAdAt: now.subtract(const Duration(hours: 1)),
        ),
        isTrue,
      );
    });

    test('needs 10 minutes since the last ad', () {
      expect(
        allows(rounds: 20, lastAdAt: now.subtract(const Duration(minutes: 9))),
        isFalse,
      );
      expect(
        allows(rounds: 20, lastAdAt: now.subtract(const Duration(minutes: 10))),
        isTrue,
      );
    });

    test('at most one per session', () {
      expect(allows(rounds: 100, shownThisSession: 1), isFalse);
    });
  });

  group('AdHistory', () {
    test('counts sessions and remembers the last ad', () async {
      SharedPreferences.setMockInitialValues({});
      final history = AdHistory(await SharedPreferences.getInstance());
      expect(await history.startSession(), 1);
      expect(await history.startSession(), 2);
      expect(history.session, 2);
      expect(history.lastAdAt, isNull);

      await history.recordShown(now, 7);
      expect(history.lastAdAt, now);
      expect(history.roundsAtLastAd, 7);
    });
  });
}
