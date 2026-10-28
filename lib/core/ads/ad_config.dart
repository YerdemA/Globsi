import 'package:flutter/foundation.dart';
import 'package:globsi/core/ads/interstitial_policy.dart';

/// Ad unit IDs. Debug and profile builds always use Google's test units;
/// release builds take real ones from `--dart-define` and show no ads when
/// they are missing. Real IDs are never written in the code (§8 rule 5).
abstract final class AdConfig {
  static const _testBanner = 'ca-app-pub-3940256099942544/9214589741';
  static const _testInterstitial = 'ca-app-pub-3940256099942544/1033173712';

  static const _banner = String.fromEnvironment('ADMOB_BANNER_ID');
  static const _interstitial = String.fromEnvironment('ADMOB_INTERSTITIAL_ID');

  /// `--dart-define=UMP_DEBUG_EEA=true` makes the consent flow behave as in
  /// the EU (debug builds only) to test the form.
  static const bool umpDebugEea =
      !kReleaseMode && bool.fromEnvironment('UMP_DEBUG_EEA');

  /// `--dart-define=ADS_DEBUG_FREQUENT=true` drops the round and time limits
  /// of the full-screen ad (debug builds only) so it can be tested by hand.
  /// The first-session and once-per-session rules still apply.
  static const bool debugFrequentInterstitial =
      !kReleaseMode && bool.fromEnvironment('ADS_DEBUG_FREQUENT');

  static InterstitialPolicy get interstitialPolicy => debugFrequentInterstitial
      ? const InterstitialPolicy(
          minRoundsBetween: 1,
          minInterval: Duration.zero,
        )
      : const InterstitialPolicy();

  static String? get bannerUnitId => _unit(_banner, _testBanner);

  static String? get interstitialUnitId =>
      _unit(_interstitial, _testInterstitial);

  static bool get hasAnyUnit =>
      bannerUnitId != null || interstitialUnitId != null;

  static String? _unit(String real, String test) {
    if (!kReleaseMode) return test;
    return real.isEmpty ? null : real;
  }
}
