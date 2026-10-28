// Builds docs/privacy-policy/index.html (GitHub Pages) from the in-app
// policy texts in assets/legal/, so both stay identical.
//
// Usage: dart run tool/build_privacy_page.dart
import 'dart:convert';
import 'dart:io';

const _languages = {'tr': 'Türkçe', 'en': 'English'};
const _output = 'docs/privacy-policy/index.html';

void main() {
  final sections = StringBuffer();
  for (final MapEntry(key: code, value: label) in _languages.entries) {
    final markdown = File('assets/legal/privacy_$code.md').readAsStringSync();
    sections
      ..writeln('<section lang="$code" id="$code">')
      ..writeln('<p class="lang">$label</p>')
      ..writeln(_toHtml(markdown))
      ..writeln('</section>');
  }

  File(_output)
    ..createSync(recursive: true)
    ..writeAsStringSync('''
<!doctype html>
<html lang="tr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Globsi – Gizlilik Politikası / Privacy Policy</title>
<style>
  :root { color-scheme: light dark; --accent: #0a5e8c; }
  body { font: 16px/1.6 system-ui, sans-serif; max-width: 720px;
         margin: 0 auto; padding: 24px 16px 48px; }
  nav a { margin-right: 16px; color: var(--accent); }
  section { margin-top: 32px; }
  .lang { text-transform: uppercase; letter-spacing: .08em; font-size: 13px;
          color: var(--accent); margin: 0; }
  h1 { margin-top: 4px; }
  a { color: var(--accent); word-break: break-all; }
  hr { margin-top: 48px; border: 0; border-top: 1px solid #8884; }
</style>
</head>
<body>
<nav><a href="#tr">Türkçe</a><a href="#en">English</a></nav>
$sections</body>
</html>
''');
  stdout.writeln('wrote $_output');
}

/// The small Markdown subset of the policy: headings, bullets, paragraphs
/// and bare https links.
String _toHtml(String markdown) {
  final out = StringBuffer();
  var inList = false;
  void closeList() {
    if (inList) out.writeln('</ul>');
    inList = false;
  }

  for (final raw in markdown.split('\n')) {
    final line = raw.trimRight();
    if (line.isEmpty) {
      closeList();
    } else if (line.startsWith('# ')) {
      closeList();
      out.writeln('<h1>${_inline(line.substring(2))}</h1>');
    } else if (line.startsWith('## ')) {
      closeList();
      out.writeln('<h2>${_inline(line.substring(3))}</h2>');
    } else if (line.startsWith('- ')) {
      if (!inList) out.writeln('<ul>');
      inList = true;
      out.writeln('<li>${_inline(line.substring(2))}</li>');
    } else {
      closeList();
      out.writeln('<p>${_inline(line)}</p>');
    }
  }
  closeList();
  return out.toString();
}

String _inline(String text) => const HtmlEscape(HtmlEscapeMode.element)
    .convert(text)
    .replaceAllMapped(
      RegExp(r'https://[^\s<]+'),
      (m) => '<a href="${m[0]}">${m[0]}</a>',
    );
