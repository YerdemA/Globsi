import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:globsi/l10n/app_localizations.dart';

/// The privacy policy from `assets/legal/privacy_<lang>.md`, readable
/// offline. The same text is published on GitHub Pages for the Play listing.
class PrivacyPolicyScreen extends StatelessWidget {
  const new({super.key});

  static String assetFor(String languageCode) =>
      'assets/legal/privacy_${languageCode == 'en' ? 'en' : 'tr'}.md';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicy)),
      body: FutureBuilder(
        future: rootBundle.loadString(assetFor(language)),
        builder: (context, snapshot) => switch (snapshot) {
          AsyncSnapshot(:final data?) => SelectionArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: markdownBlocks(context, data),
            ),
          ),
          AsyncSnapshot(hasError: true) => Center(child: Text(l10n.loadError)),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

/// Renders the small Markdown subset used by the policy: `#`/`##` headings,
/// `-` bullets and paragraphs.
List<Widget> markdownBlocks(BuildContext context, String markdown) {
  final text = Theme.of(context).textTheme;
  return [
    for (final line in markdown.split('\n').map((l) => l.trimRight()))
      if (line.isEmpty)
        const SizedBox(height: 8)
      else if (line.startsWith('# '))
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(line.substring(2), style: text.headlineSmall),
        )
      else if (line.startsWith('## '))
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(line.substring(3), style: text.titleMedium),
        )
      else if (line.startsWith('- '))
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•  ', style: text.bodyMedium),
              Expanded(child: Text(line.substring(2), style: text.bodyMedium)),
            ],
          ),
        )
      else
        Text(line, style: text.bodyMedium),
  ];
}
