import 'package:flutter/material.dart';
import 'package:globsi/l10n/app_localizations.dart';

/// Temporary body for screens that are implemented in later phases.
class PlaceholderScreen extends StatelessWidget {
  const new({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(AppLocalizations.of(context).comingSoon)),
    );
  }
}
