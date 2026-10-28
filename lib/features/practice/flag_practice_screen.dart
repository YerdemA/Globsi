import 'package:flutter/material.dart';
import 'package:globsi/features/practice/engine/practice_filter.dart';
import 'package:globsi/features/practice/practice_screen.dart';

/// Flag practice: name the country of the flag.
class FlagPracticeScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) =>
      const PracticeScreen(mode: PracticeMode.flag);
}
