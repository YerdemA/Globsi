// Copies the flag SVGs referenced by assets/data/countries.json into
// assets/flags/, from lipis/flag-icons (MIT) and tool/flags_extra/ (public
// domain flags missing from flag-icons). Unreferenced flags are removed.
//
// Usage: dart run tool/copy_flags.dart [--source=<flag-icons>/flags/4x3]
import 'dart:convert';
import 'dart:io';

const _countriesPath = 'assets/data/countries.json';
const _outputDir = 'assets/flags';
const _extraDir = 'tool/flags_extra';

void main(List<String> args) {
  final source =
      args
          .where((a) => a.startsWith('--source='))
          .map((a) => a.substring('--source='.length))
          .firstOrNull ??
      'tool/raw/flag-icons/package/flags/4x3';

  final countries = (jsonDecode(
    File(_countriesPath).readAsStringSync(),
  ) as List).cast<Map<String, Object?>>();
  final wanted = {for (final c in countries) c['flag']! as String};

  Directory(_outputDir).createSync(recursive: true);
  final missing = <String>[];
  var fromExtra = 0;
  for (final name in wanted) {
    final extra = File('$_extraDir/$name');
    final icon = File('$source/$name');
    final file = extra.existsSync() ? extra : icon;
    if (!file.existsSync()) {
      missing.add(name);
      continue;
    }
    if (file == extra) fromExtra++;
    file.copySync('$_outputDir/$name');
  }

  var removed = 0;
  for (final f in Directory(_outputDir).listSync().whereType<File>()) {
    if (!wanted.contains(f.uri.pathSegments.last)) {
      f.deleteSync();
      removed++;
    }
  }

  stdout.writeln(
    'copied ${wanted.length - missing.length} flags '
    '($fromExtra from $_extraDir), removed $removed',
  );
  if (missing.isNotEmpty) {
    stderr.writeln('missing: ${missing.join(' ')}');
    exitCode = 1;
  }
}
