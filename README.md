# Globsi

Android için çevrimdışı çalışan coğrafya öğrenme uygulaması: döndürülebilir
küre, bayrak öğrenme, harita ve bayrak pratiği. Proje kararları
[`CLAUDE.md`](CLAUDE.md), aşamalı plan [`docs/ROADMAP.md`](docs/ROADMAP.md)
içindedir.

## Geliştirme

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Reklamlar

Debug ve profile derlemeleri her zaman Google'ın test reklamlarını kullanır.
Gerçek AdMob kimlikleri koda yazılmaz; release derlemesinde verilir:

```bash
flutter build appbundle --release \
  -P ADMOB_APP_ID=ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY \
  --dart-define=ADMOB_BANNER_ID=ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ \
  --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-XXXXXXXXXXXXXXXX/WWWWWWWWWW
```

Birim kimlikleri verilmezse release derlemesinde reklam gösterilmez.
`ADMOB_APP_ID` ortam değişkeni olarak da verilebilir.

Elle test için (yalnızca debug):

- `--dart-define=ADS_DEBUG_FREQUENT=true` — tam ekran reklamın tur/süre
  sınırlarını kaldırır.
- `--dart-define=UMP_DEBUG_EEA=true` — onay formunu AB'deymiş gibi açar
  (AdMob'da gizlilik mesajı yayınlanmış olmalı).

Kurallar ve test listesi: `CLAUDE.md` §8, [`docs/ADS_TEST_CHECKLIST.md`](docs/ADS_TEST_CHECKLIST.md).

## Veri hattı

Uygulamanın kullandığı işlenmiş veriler repoda hazırdır:

| Dosya | İçerik | Üreten |
|---|---|---|
| `assets/data/countries.json` | Ülke meta verisi (ad, başkent, kıta, …) | Elle düzenlenir; `centroid`, `isTiny`, `neighbors` alanlarını araç günceller |
| `assets/geo/countries.geo.bin` | Sadeleştirilmiş sınırlar (ikili format) | `tool/build_geo_data.dart` |
| `assets/flags/*.svg` | Bayraklar | `tool/copy_flags.dart` |

Ham kaynaklar repoya eklenmez (`tool/raw/` `.gitignore` içindedir). Veriyi
yeniden üretmek için:

### 1. Natural Earth sınırlarını indir (1:50m, kamu malı)

GeoJSON sürümleri [nvkelso/natural-earth-vector](https://github.com/nvkelso/natural-earth-vector)
deposundan alınır:

```bash
mkdir -p tool/raw
base=https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson
for f in ne_50m_admin_0_map_subunits \
         ne_50m_admin_0_breakaway_disputed_areas \
         ne_50m_admin_0_countries; do
  curl -L -o tool/raw/$f.geojson $base/$f.geojson
done
```

- `map_subunits`: geometri kaynağı (Kırım ayrı bir alt birim olduğu için).
- `breakaway_disputed_areas`: Golan, Abhazya ve Güney Osetya'nın iç sınır hatları.
- `countries`: yalnızca etiket noktaları (`LABEL_X`/`LABEL_Y`).

### 2. Sınır verisini üret

```bash
dart run tool/build_geo_data.dart            # varsayılan tolerans 0.01°
dart run tool/build_geo_data.dart --tolerance=0.02 --raw=tool/raw
```

Araç sınır kararlarını (`CLAUDE.md` §4.2) uygular, paylaşılan sınırları
topolojiye duyarlı Douglas–Peucker ile sadeleştirir, `countries.geo.bin`
dosyasını yazar ve `countries.json` içindeki üretilen alanları günceller.

### 3. Bayrakları kopyala

```bash
mkdir -p tool/raw/flag-icons
curl -L https://registry.npmjs.org/flag-icons/-/flag-icons-7.6.0.tgz \
  | tar xz -C tool/raw/flag-icons
dart run tool/copy_flags.dart
```

flag-icons'ta olmayan bayraklar (KKTC, Somaliland, Abhazya, Güney Osetya)
`tool/flags_extra/` klasöründen alınır.

### 4. Doğrula

```bash
flutter test test/data/data_validation_test.dart
```

Lisanslar: [`docs/ATTRIBUTIONS.md`](docs/ATTRIBUTIONS.md).
