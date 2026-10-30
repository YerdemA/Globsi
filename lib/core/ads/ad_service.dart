import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globsi/core/ads/ad_config.dart';
import 'package:globsi/core/ads/ad_history.dart';
import 'package:globsi/core/ads/interstitial_policy.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A loaded banner ready to be placed.
class LoadedBanner {
  new({required this.widget, required this.height, this.dispose});

  final Widget widget;
  final double height;
  final VoidCallback? dispose;
}

/// Everything the UI needs from ads. Every method returns quickly and never
/// throws: a missing or failed ad must not hold up or break the app (§8).
abstract class AdService {
  /// Becomes true once consent allows requesting ads.
  ValueListenable<bool> get canRequestAds;

  /// Whether Settings must offer "Privacy options" (EU/UK users).
  ValueListenable<bool> get privacyOptionsRequired;

  /// Gathers consent and starts the ads SDK. Fire and forget at startup.
  Future<void> initialize();

  Future<void> showPrivacyOptions();

  /// An adaptive banner for [width] logical pixels, or `null` (disabled,
  /// no consent, or failed to load).
  Future<LoadedBanner?> loadBanner(double width);

  /// The round summary is visible: preload a full-screen ad if one may be
  /// shown when the user leaves it.
  void prepareInterstitial(int roundsCompleted);

  /// The user leaves the round summary: show the full-screen ad if it is
  /// loaded and allowed. Does not wait for it.
  void onLeaveSummary(int roundsCompleted);
}

/// No ads at all (tests, and release builds without ad unit IDs).
class NoAdService implements AdService {
  @override
  final ValueListenable<bool> canRequestAds = ValueNotifier(false);

  @override
  final ValueListenable<bool> privacyOptionsRequired = ValueNotifier(false);

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showPrivacyOptions() async {}

  @override
  Future<LoadedBanner?> loadBanner(double width) async => null;

  @override
  void prepareInterstitial(int roundsCompleted) {}

  @override
  void onLeaveSummary(int roundsCompleted) {}
}

/// Overridden in `main` with [GoogleAdService].
final adServiceProvider = Provider<AdService>((ref) => NoAdService());

/// AdMob with the Google UMP consent flow.
class GoogleAdService implements AdService {
  new(
    this._history, {
    this.policy = const InterstitialPolicy(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AdHistory _history;
  final InterstitialPolicy policy;
  final DateTime Function() _clock;

  static const int _maxBannerHeight = 60;

  final ValueNotifier<bool> _canRequestAds = ValueNotifier(false);
  final ValueNotifier<bool> _privacyRequired = ValueNotifier(false);
  bool _sdkStarted = false;
  int _shownThisSession = 0;
  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;

  @override
  ValueListenable<bool> get canRequestAds => _canRequestAds;

  @override
  ValueListenable<bool> get privacyOptionsRequired => _privacyRequired;

  @override
  Future<void> initialize() async {
    if (!AdConfig.hasAnyUnit) return;
    try {
      final params = ConsentRequestParameters(
        consentDebugSettings: AdConfig.umpDebugEea
            ? ConsentDebugSettings(
                debugGeography: DebugGeography.debugGeographyEea,
                testIdentifiers: [
                  if (AdConfig.umpTestDevice.isNotEmpty) AdConfig.umpTestDevice,
                ],
              )
            : null,
      );
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () => unawaited(
          ConsentForm.loadAndShowConsentFormIfRequired(
            (_) => unawaited(_afterConsent()),
          ),
        ),
        (_) => unawaited(_afterConsent()),
      );
      // Consent from an earlier session lets ads start without waiting
      // for the update above.
      await _afterConsent();
    } on Object catch (e) {
      debugPrint('Ads disabled: $e');
    }
  }

  Future<void> _afterConsent() async {
    try {
      final info = ConsentInformation.instance;
      _privacyRequired.value =
          await info.getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
      if (_sdkStarted || !await info.canRequestAds()) return;
      _sdkStarted = true;
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(maxAdContentRating: MaxAdContentRating.pg),
      );
      await MobileAds.instance.initialize();
      _canRequestAds.value = true;
    } on Object catch (e) {
      debugPrint('Ads not started: $e');
    }
  }

  @override
  Future<void> showPrivacyOptions() async {
    try {
      await ConsentForm.showPrivacyOptionsForm(
        (_) => unawaited(_afterConsent()),
      );
    } on Object catch (e) {
      debugPrint('Privacy options failed: $e');
    }
  }

  @override
  Future<LoadedBanner?> loadBanner(double width) async {
    final unit = AdConfig.bannerUnitId;
    if (unit == null || !_canRequestAds.value) return null;
    try {
      // Adaptive width, but capped at a classic banner height so the ad
      // stays unobtrusive (large anchored banners can exceed 100 dp).
      final size = AdSize.getInlineAdaptiveBannerAdSize(
        width.truncate(),
        _maxBannerHeight,
      );
      final loaded = Completer<LoadedBanner?>();
      final banner = BannerAd(
        adUnitId: unit,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          // Refreshes call these again later; only the first result counts.
          onAdLoaded: (ad) async {
            if (loaded.isCompleted) return;
            final actual = await (ad as BannerAd).getPlatformAdSize();
            if (loaded.isCompleted) return;
            loaded.complete(
              LoadedBanner(
                widget: AdWidget(ad: ad),
                height: (actual?.height ?? _maxBannerHeight).toDouble(),
                dispose: () => unawaited(ad.dispose()),
              ),
            );
          },
          onAdFailedToLoad: (ad, _) {
            // A failed refresh keeps showing the previous ad.
            if (loaded.isCompleted) return;
            unawaited(ad.dispose());
            loaded.complete(null);
          },
        ),
      );
      await banner.load();
      return await loaded.future;
    } on Object catch (e) {
      debugPrint('Banner failed: $e');
      return null;
    }
  }

  bool _allowed(int roundsCompleted) => policy.allows(
    session: _history.session,
    roundsCompleted: roundsCompleted,
    roundsAtLastAd: _history.roundsAtLastAd,
    lastAdAt: _history.lastAdAt,
    shownThisSession: _shownThisSession,
    now: _clock(),
  );

  @override
  void prepareInterstitial(int roundsCompleted) {
    final unit = AdConfig.interstitialUnitId;
    final allowed = _allowed(roundsCompleted);
    if (kDebugMode) {
      debugPrint(
        'Interstitial: session=${_history.session} '
        'rounds=$roundsCompleted lastRounds=${_history.roundsAtLastAd} '
        'shown=$_shownThisSession consent=${_canRequestAds.value} '
        'allowed=$allowed',
      );
    }
    if (unit == null ||
        !_canRequestAds.value ||
        _interstitial != null ||
        _loadingInterstitial ||
        !allowed) {
      return;
    }
    _loadingInterstitial = true;
    unawaited(
      InterstitialAd.load(
        adUnitId: unit,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _loadingInterstitial = false;
            _interstitial = ad;
          },
          onAdFailedToLoad: (_) => _loadingInterstitial = false,
        ),
      ).catchError((Object _) => _loadingInterstitial = false),
    );
  }

  @override
  void onLeaveSummary(int roundsCompleted) {
    final ad = _interstitial;
    if (ad == null || !_allowed(roundsCompleted)) return;
    _interstitial = null;
    _shownThisSession++;
    unawaited(_history.recordShown(_clock(), roundsCompleted));
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) => unawaited(ad.dispose()),
      onAdFailedToShowFullScreenContent: (ad, _) => unawaited(ad.dispose()),
    );
    unawaited(ad.show().catchError((Object _) {}));
  }
}
