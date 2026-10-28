import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globsi/core/ads/ad_service.dart';

/// A single adaptive banner for the bottom of a screen. Takes no space until
/// an ad has loaded, and stays empty if loading fails (§8).
///
/// Only used on the home menu, the flag list and the round summary.
class AdBanner extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends ConsumerState<AdBanner> {
  LoadedBanner? _banner;
  bool _requested = false;
  late final AdService _service = ref.read(adServiceProvider);

  @override
  void initState() {
    super.initState();
    _service.canRequestAds.addListener(_onConsentChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _onConsentChanged();
  }

  void _onConsentChanged() => unawaited(_maybeLoad());

  Future<void> _maybeLoad() async {
    if (_requested || !_service.canRequestAds.value || !mounted) return;
    _requested = true;
    final width = MediaQuery.sizeOf(context).width;
    LoadedBanner? banner;
    try {
      banner = await _service.loadBanner(width);
    } on Object {
      banner = null;
    }
    if (!mounted) {
      banner?.dispose?.call();
      return;
    }
    setState(() => _banner = banner);
  }

  @override
  void dispose() {
    _service.canRequestAds.removeListener(_onConsentChanged);
    _banner?.dispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    if (banner == null) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        height: banner.height,
        width: double.infinity,
        child: Center(child: banner.widget),
      ),
    );
  }
}
