import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globsi/core/data/country.dart';
import 'package:globsi/core/geo/geo_codec.dart';
import 'package:globsi/core/geo/geo_data.dart';

/// All countries, in `countries.json` order, with lookup by id.
class CountryCatalog {
  new(this.countries) : _byId = {for (final c in countries) c.id: c};

  final List<Country> countries;
  final Map<String, Country> _byId;

  Country? operator [](String id) => _byId[id];
}

/// Loads country metadata and boundary data from assets, once.
class CountryRepository {
  new(this._bundle);

  static const countriesAsset = 'assets/data/countries.json';
  static const geoAsset = 'assets/geo/countries.geo.bin';

  final AssetBundle _bundle;
  Future<CountryCatalog>? _catalog;
  Future<GeoDataset>? _geo;

  Future<CountryCatalog> loadCatalog() =>
      _catalog ??= _retryOnError(_loadCatalog, () => _catalog = null);

  Future<GeoDataset> loadGeo() =>
      _geo ??= _retryOnError(_loadGeo, () => _geo = null);

  Future<CountryCatalog> _loadCatalog() async {
    final json = jsonDecode(await _bundle.loadString(countriesAsset));
    return CountryCatalog([
      for (final c in (json as List<Object?>).cast<Map<String, Object?>>())
        Country.fromJson(c),
    ]);
  }

  Future<GeoDataset> _loadGeo() async =>
      GeoCodec.decode(await _bundle.load(geoAsset));

  /// Drops a failed load from the cache so the next call tries again.
  static Future<T> _retryOnError<T>(
    Future<T> Function() load,
    void Function() reset,
  ) async {
    try {
      return await load();
    } catch (_) {
      reset();
      rethrow;
    }
  }
}

final countryRepositoryProvider = Provider<CountryRepository>(
  (ref) => CountryRepository(rootBundle),
);

final countryCatalogProvider = FutureProvider<CountryCatalog>(
  (ref) => ref.watch(countryRepositoryProvider).loadCatalog(),
);

final geoDatasetProvider = FutureProvider<GeoDataset>(
  (ref) => ref.watch(countryRepositoryProvider).loadGeo(),
);
