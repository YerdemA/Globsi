import 'package:flutter/material.dart';
import 'package:globsi/features/home/placeholder_screen.dart';
import 'package:globsi/l10n/app_localizations.dart';

class FlagPracticeScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: AppLocalizations.of(context).menuFlagPractice,
    );
  }
}
