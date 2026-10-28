// Renders the Play Store graphics into docs/store/:
//   icon-512.png             512×512 app icon (full square; Play masks it)
//   feature-graphic.png      1024×500 feature graphic
//
// Run with: flutter test tool/store/render_store_assets_test.dart
@Tags(['store'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/core/ui/app_logo.dart';

/// Test fonts draw boxes; load Roboto from the Flutter SDK instead.
Future<void> _loadRoboto() async {
  final flutterRoot = File(Platform.resolvedExecutable)
      .parent
      .parent
      .parent
      .parent
      .parent
      .parent
      .path;
  final dir = '$flutterRoot/bin/cache/artifacts/material_fonts';
  final loader = FontLoader('Roboto');
  for (final name in ['roboto-regular.ttf', 'roboto-bold.ttf']) {
    final file = File('$dir/$name');
    if (file.existsSync()) {
      loader.addFont(
        Future.value(ByteData.sublistView(file.readAsBytesSync())),
      );
    }
  }
  await loader.load();
}

Future<void> _render(
  WidgetTester tester,
  Widget child,
  Size size,
  String path,
) async {
  final key = GlobalKey();
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: RepaintBoundary(
        key: key,
        child: Material(type: MaterialType.transparency, child: child),
      ),
    ),
  );
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(_loadRoboto);

  testWidgets('icon 512', (tester) async {
    await _render(
      tester,
      const CustomPaint(
        size: Size.square(512),
        painter: AppLogoPainter(zoom: 1.45),
      ),
      const Size(512, 512),
      'docs/store/icon-512.png',
    );
  });

  testWidgets('feature graphic 1024×500', (tester) async {
    await _render(
      tester,
      const _FeatureGraphic(),
      const Size(1024, 500),
      'docs/store/feature-graphic.png',
    );
  });
}

class _FeatureGraphic extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A5E8C), Color(0xFF0B3D63)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 72),
        child: Row(
          spacing: 48,
          children: [
            const SizedBox.square(
              dimension: 300,
              child: CustomPaint(
                painter: AppLogoPainter(background: false, zoom: 2.2),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  const Text(
                    'Globsi',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 96,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  Text(
                    'Küreyi keşfet, bayrakları öğren',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 34,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
