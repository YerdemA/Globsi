import 'package:flutter/material.dart';
import 'package:globsi/features/practice/engine/practice_filter.dart';
import 'package:globsi/features/practice/practice_screen.dart';

/// Map practice: name the highlighted country.
class MapPracticeScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) =>
      const PracticeScreen(mode: PracticeMode.map);
}
