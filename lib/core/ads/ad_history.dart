import 'package:shared_preferences/shared_preferences.dart';

/// Ad-related counters kept on the device: app sessions and when the last
/// full-screen ad was shown.
class AdHistory {
  new(this._prefs);

  static const _sessionKey = 'ads.session';
  static const _lastAtKey = 'ads.lastAt';
  static const _lastRoundsKey = 'ads.lastRounds';

  final SharedPreferences _prefs;

  /// Counts this app launch; call once at startup. Returns the session
  /// number, 1 for the very first launch.
  Future<int> startSession() async {
    final session = (_prefs.getInt(_sessionKey) ?? 0) + 1;
    await _prefs.setInt(_sessionKey, session);
    return session;
  }

  int get session => _prefs.getInt(_sessionKey) ?? 0;

  DateTime? get lastAdAt {
    final ms = _prefs.getInt(_lastAtKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  int get roundsAtLastAd => _prefs.getInt(_lastRoundsKey) ?? 0;

  Future<void> recordShown(DateTime at, int roundsCompleted) async {
    await _prefs.setInt(_lastAtKey, at.millisecondsSinceEpoch);
    await _prefs.setInt(_lastRoundsKey, roundsCompleted);
  }
}
