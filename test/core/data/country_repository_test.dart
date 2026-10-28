import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:globsi/core/data/country.dart';
import 'package:globsi/core/data/country_repository.dart';

/// Serves assets from the project directory and counts loads.
class _FileBundle extends CachingAssetBundle {
  int loads = 0;
  bool fail = false;

  @override
  Future<ByteData> load(String key) async {
    loads++;
    if (fail) throw StateError('unavailable');
    return ByteData.sublistView(await File(key).readAsBytes());
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final data = await load(key);
    return utf8.decode(Uint8List.sublistView(data));
  }
}

void main() {
  test('loads the catalog once and looks countries up by id', () async {
    final bundle = _FileBundle();
    final repository = CountryRepository(bundle);

    final catalog = await repository.loadCatalog();
    await repository.loadCatalog();

    expect(bundle.loads, 1);
    expect(catalog.countries, hasLength(202));
    final turkey = catalog['TR']!;
    expect(turkey.name.resolve('tr'), 'Türkiye');
    expect(turkey.capital.resolve('en'), 'Ankara');
    expect(turkey.continent, Continent.europe);
    expect(turkey.flagAsset, 'assets/flags/tr.svg');
    expect(catalog['XX'], isNull);
  });

  test('loads and caches the geo dataset', () async {
    final bundle = _FileBundle();
    final repository = CountryRepository(bundle);

    final geo = await repository.loadGeo();
    expect(identical(geo, await repository.loadGeo()), isTrue);
    expect(bundle.loads, 1);
    expect(geo.featureById('VA'), isNotNull);
  });

  test('retries after a failed load', () async {
    final bundle = _FileBundle()..fail = true;
    final repository = CountryRepository(bundle);

    await expectLater(repository.loadCatalog(), throwsA(anything));
    bundle.fail = false;
    expect((await repository.loadCatalog()).countries, isNotEmpty);
  });
}
