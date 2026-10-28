import 'package:flutter/material.dart';

enum OptionFeedback { none, correct, wrong, dimmed }

/// Answer colors that read well in light and dark themes.
abstract final class AnswerColors {
  static Color correct(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);

  static Color wrong(ColorScheme scheme) => scheme.error;
}

/// A full-width answer choice. After answering it shows feedback with both
/// color and an icon (✓ / ✗), so it does not rely on color alone.
class OptionButton extends StatelessWidget {
  const new({
    required this.label,
    required this.feedback,
    required this.onPressed,
    super.key,
  });

  final String label;
  final OptionFeedback feedback;

  /// `null` once the question is answered.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (Color? accent, IconData? icon) = switch (feedback) {
      OptionFeedback.correct => (
        AnswerColors.correct(theme.brightness),
        Icons.check_circle,
      ),
      OptionFeedback.wrong => (AnswerColors.wrong(scheme), Icons.cancel),
      OptionFeedback.none || OptionFeedback.dimmed => (null, null),
    };

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        alignment: Alignment.centerLeft,
        backgroundColor: accent?.withValues(alpha: 0.14),
        side: BorderSide(
          color: accent ?? scheme.outline,
          width: accent == null ? 1 : 2,
        ),
        disabledForegroundColor: feedback == OptionFeedback.dimmed
            ? scheme.onSurface.withValues(alpha: 0.5)
            : scheme.onSurface,
      ),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: feedback == OptionFeedback.dimmed
                    ? scheme.onSurface.withValues(alpha: 0.5)
                    : scheme.onSurface,
              ),
            ),
          ),
          if (icon != null) Icon(icon, color: accent),
        ],
      ),
    );
  }
}
