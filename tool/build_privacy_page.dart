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
  final links = _languages.entries
      .map((e) => '<a href="#${e.key}" hreflang="${e.key}">${e.value}</a>')
      .join();
  for (final code in _languages.keys) {
    final markdown = File('assets/legal/privacy_$code.md').readAsStringSync();
    sections
      ..writeln('<section lang="$code" id="$code">')
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
  /* App colors: night-indigo header band, a reading column under it, and the
     star amber of the icon as the only accent. No web fonts: this page
     should not send visitors' data to a font host. */
  :root {
    color-scheme: light;
    --band: #14194a;
    --on-band: #ffffff;
    --bg: #f4f8fa;
    --text: #141b33;
    --muted: #55607a;
    --rule: #d6e3e8;
    --link: #0b7a72;
    --marker: #c98a00;
  }
  @media (prefers-color-scheme: dark) {
    :root {
      color-scheme: dark;
      --band: #14194a;
      --bg: #0f1433;
      --text: #e6eaf5;
      --muted: #9ca6c4;
      --rule: #2a3360;
      --link: #5fe0d4;
      --marker: #ffc145;
    }
  }
  * { box-sizing: border-box; }
  html { -webkit-text-size-adjust: 100%; }
  body { margin: 0; background: var(--bg); color: var(--text);
         font: 17px/1.65 system-ui, -apple-system, "Segoe UI", Roboto,
               "Helvetica Neue", Arial, sans-serif; }
  .wrap { max-width: 680px; margin: 0 auto; padding: 0 20px; }
  header { background: var(--band); color: var(--on-band); }
  .bar { display: flex; flex-wrap: wrap; align-items: center;
         justify-content: space-between; gap: 12px; padding-block: 14px; }
  .brand { display: flex; align-items: center; gap: 10px;
           font-size: 20px; font-weight: 600; }
  .brand svg { width: 36px; height: 36px; display: block; }
  nav { display: flex; gap: 4px; }
  nav a { color: var(--on-band); text-decoration: none; font-size: 15px;
          padding: 10px 14px; border-radius: 8px; }
  nav a:hover { background: #ffffff22; }
  nav a:focus-visible, a:focus-visible { outline: 2px solid currentColor;
                                         outline-offset: 2px; }
  main.wrap { padding-block: 40px 64px; }
  section { scroll-margin-top: 200px; }
  /* One language at a time; browsers without :has() show both, one after
     the other. */
  body:not(:has(#en:target)) #en, body:has(#en:target) #tr { display: none; }
  body:not(:has(#en:target)) nav a[href="#tr"],
  body:has(#en:target) nav a[href="#en"] { background: #ffffff2e;
                                           font-weight: 600; }
  h1 { font-size: clamp(30px, 7vw, 40px); line-height: 1.15; margin: 0 0 8px;
       text-wrap: balance; }
  .meta { color: var(--muted); font-size: 15px; margin: 0 0 28px; }
  h2 { font-size: 21px; line-height: 1.3; margin: 40px 0 10px;
       padding-top: 28px; border-top: 1px solid var(--rule);
       text-wrap: balance; }
  p { margin: 0 0 14px; }
  ul { margin: 0 0 14px; padding-left: 20px; display: grid; gap: 10px; }
  li::marker { color: var(--marker); }
  a { color: var(--link); overflow-wrap: anywhere; }
</style>
</head>
<body>
<header>
<div class="wrap bar">
<div class="brand">
<svg viewBox="16 16 76 76" aria-hidden="true">
<defs><radialGradient id="arm" gradientUnits="userSpaceOnUse" cx="54" cy="54" r="33"><stop offset="0.42" stop-color="#BDF2EB"/><stop offset="0.8" stop-color="#35D0C4"/></radialGradient>
<radialGradient id="globe" gradientUnits="userSpaceOnUse" cx="54" cy="54" r="14"><stop offset="0.45" stop-color="#fff"/><stop offset="1" stop-color="#BDF2EB"/></radialGradient></defs>
<path fill="url(#arm)" d="M41.88,61 L41.06,59.61 L40.26,58.18 L39.61,56.63 L39.12,54.99 L38.78,53.28 L38.6,51.49 L38.61,49.64 L38.82,47.75 L39.25,45.86 L39.92,43.97 L40.82,42.13 L41.97,40.38 L43.35,38.74 L44.96,37.26 L46.78,35.96 L48.78,34.88 L50.94,34.05 L53.22,33.48 L55.59,33.2 L58.01,33.18 L60.47,33.44 L62.92,33.97 L65.34,34.79 L67.69,35.89 L69.95,37.27 L72.08,38.93 L74.04,40.85 L75.81,43.02 L77.35,45.42 L78.64,48.02 L79.65,50.81 L80.34,53.75 L80.71,56.81 L80.73,59.95 L80.38,63.13 L79.66,66.31 L78.56,69.46 L77.09,72.51 L75.23,75.44 L73.02,78.18 L70.45,80.7 L67.56,82.95 L64.36,84.9 L60.9,86.47 L60.82,86.08 L64.16,84.3 L67.2,82.2 L69.91,79.83 L72.27,77.23 L74.26,74.45 L75.86,71.53 L77.09,68.53 L77.94,65.49 L78.42,62.45 L78.53,59.46 L78.31,56.56 L77.77,53.77 L76.93,51.15 L75.83,48.71 L74.48,46.47 L72.94,44.46 L71.22,42.7 L69.36,41.19 L67.4,39.94 L65.37,38.96 L63.3,38.23 L61.23,37.76 L59.17,37.54 L57.17,37.56 L55.24,37.79 L53.4,38.23 L51.67,38.82 L50.05,39.54 L48.55,40.38 L47.16,41.33 L45.89,42.37 L44.73,43.51 L43.69,44.72 L42.78,46.01 L42,47.37 L41.35,48.8 L40.85,50.27 L40.5,51.8 L40.31,53.35 L40.29,54.91 L40.46,56.48 L40.76,58.02 L41.2,59.56 L41.88,61Z"/>
<path fill="url(#arm)" d="M66.12,47 L66.94,48.39 L67.74,49.82 L68.39,51.37 L68.88,53.01 L69.22,54.72 L69.4,56.51 L69.39,58.36 L69.18,60.25 L68.75,62.14 L68.08,64.03 L67.18,65.87 L66.03,67.62 L64.65,69.26 L63.04,70.74 L61.22,72.04 L59.22,73.12 L57.06,73.95 L54.78,74.52 L52.41,74.8 L49.99,74.82 L47.53,74.56 L45.08,74.03 L42.66,73.21 L40.31,72.11 L38.05,70.73 L35.92,69.07 L33.96,67.15 L32.19,64.98 L30.65,62.58 L29.36,59.98 L28.35,57.19 L27.66,54.25 L27.29,51.19 L27.27,48.05 L27.62,44.87 L28.34,41.69 L29.44,38.54 L30.91,35.49 L32.77,32.56 L34.98,29.82 L37.55,27.3 L40.44,25.05 L43.64,23.1 L47.1,21.53 L47.18,21.92 L43.84,23.7 L40.8,25.8 L38.09,28.17 L35.73,30.77 L33.74,33.55 L32.14,36.47 L30.91,39.47 L30.06,42.51 L29.58,45.55 L29.47,48.54 L29.69,51.44 L30.23,54.23 L31.07,56.85 L32.17,59.29 L33.52,61.53 L35.06,63.54 L36.78,65.3 L38.64,66.81 L40.6,68.06 L42.63,69.04 L44.7,69.77 L46.77,70.24 L48.83,70.46 L50.83,70.44 L52.76,70.21 L54.6,69.77 L56.33,69.18 L57.95,68.46 L59.45,67.62 L60.84,66.67 L62.11,65.63 L63.27,64.49 L64.31,63.28 L65.22,61.99 L66,60.63 L66.65,59.2 L67.15,57.73 L67.5,56.2 L67.69,54.65 L67.71,53.09 L67.54,51.52 L67.24,49.98 L66.8,48.44 L66.12,47Z"/>
<circle cx="54" cy="54" r="14" fill="url(#globe)"/>
<g fill="none" stroke="#14194A" stroke-width="1.5" stroke-linecap="round"><ellipse cx="54" cy="54" rx="5.8" ry="13.25"/><path d="M40.75,54H67.25"/></g>
<path fill="#FFC145" d="M79,22.5 L79.74,28.26 L85.5,29 L79.74,29.74 L79,35.5 L78.26,29.74 L72.5,29 L78.26,28.26Z"/>
</svg>
Globsi
</div>
<nav>$links</nav>
</div>
</header>
<main class="wrap">
$sections</main>
</body>
</html>
''');
  stdout.writeln('wrote $_output');
}

/// The small Markdown subset of the policy: headings, bullets, paragraphs
/// and bare https links and e-mail addresses. The paragraph right after the
/// title is the date line.
String _toHtml(String markdown) {
  final out = StringBuffer();
  var inList = false;
  var afterTitle = false;
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
      afterTitle = true;
    } else if (line.startsWith('## ')) {
      closeList();
      out.writeln('<h2>${_inline(line.substring(3))}</h2>');
    } else if (line.startsWith('- ')) {
      if (!inList) out.writeln('<ul>');
      inList = true;
      out.writeln('<li>${_inline(line.substring(2))}</li>');
    } else {
      closeList();
      final attributes = afterTitle ? ' class="meta"' : '';
      afterTitle = false;
      out.writeln('<p$attributes>${_inline(line)}</p>');
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
    )
    .replaceAllMapped(
      RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+'),
      (m) => '<a href="mailto:${m[0]}">${m[0]}</a>',
    );
