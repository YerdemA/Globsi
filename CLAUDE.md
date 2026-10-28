# Globsi — Claude Code Proje Rehberi

Globsi, Android için çevrimdışı çalışan bir coğrafya öğrenme uygulamasıdır. Kullanıcı ülkelerin konumlarını döndürülebilir bir küre üzerinde keşfeder, bayrakları öğrenir ve iki pratik moduyla kendini test eder.

- **Geliştirici:** Yusuf Erdem Aykaç (GitHub: `YerdemA`)
- **Paket adı:** `com.yerdema.globsi`
- **Platform:** Yalnızca Android (ilk sürüm)
- **Diller:** Türkçe (varsayılan) + İngilizce
- **Hedef:** Küçük APK boyutu, akıcı performans, sade ve anlaşılır arayüz, kullanıcıyı rahatsız etmeyen reklam

Bu dosya projenin kalıcı kararlarını içerir. Aşamalı iş planı `docs/ROADMAP.md` dosyasındadır. Her oturumda önce ROADMAP'teki güncel aşamaya bak.

---

## 1. İlk sürüm kapsamı (v1.0)

1. **Küre (Keşfet):** Döndürülebilir, yakınlaştırılıp uzaklaştırılabilir 3B görünümlü dünya küresi. Bir ülkeye dokununca ülke vurgulanır ve alttan bir **bilgi kartı** açılır: ülke adı, bayrak, başkent, kıta.
2. **Bayrak öğrenme modu:** İki alt görünüm:
   - **Liste/ızgara:** Kıtaya göre gruplu bayraklar. Dokununca detay açılır.
   - **Kart çevirme:** Bayrak gösterilir, dokununca kart çevrilip ülke adı ve kısa bilgi çıkar, kaydırarak sonrakine geçilir. Kıta seçilebilir.
3. **Harita pratiği:** Kürede rastgele bir ülke vurgulanır ve 4 isim şıkkı sunulur. Kullanıcı seçer, doğru cevap gösterilir.
4. **Bayrak pratiği:** Rastgele bir bayrak gösterilir ve 4 isim şıkkı sunulur. Kullanıcı seçer, doğru cevap gösterilir.

**Kapsam dışı (v1.0):** Hesap/giriş, bulut senkronizasyonu, iOS, çevrimiçi skor tablosu, sesli içerik, uygulama içi satın alma.

---

## 2. Teknoloji yığını

| Alan | Seçim |
|---|---|
| Framework | Flutter (en güncel stable), Dart null-safety |
| Durum yönetimi | `flutter_riverpod` |
| Yönlendirme | `go_router` |
| Bayrak çizimi | `flutter_svg` |
| Yerel kayıt | `shared_preferences` (istatistik JSON olarak). İhtiyaç büyürse Hive'a geçilebilir. |
| Yerelleştirme | `flutter_localizations` + `intl`, ARB dosyaları (`lib/l10n/app_tr.arb`, `app_en.arb`) |
| Reklam | `google_mobile_ads` + Google UMP onay akışı |
| Test | `flutter_test`, mantık katmanı için birim testleri |

Yeni bir paket eklemeden önce gerekli olup olmadığını sorgula. APK boyutu önemlidir. Küre çizimi için harici 3B/WebView paketi **kullanılmaz**.

---

## 3. Klasör yapısı

```
lib/
  main.dart
  app/                 # MaterialApp, tema, router, l10n kurulumu
  core/
    geo/               # projeksiyon matematiği, rotasyon, hit-test (saf Dart, Flutter'a bağımsız)
    data/              # varlık yükleme, modeller, repository'ler
    stats/             # yerel istatistik servisi
    ads/               # reklam servisi ve sıklık kontrolü
  features/
    globe/             # küre ekranı, GlobePainter, bilgi kartı
    flags_learn/       # liste/ızgara + kart çevirme
    practice/          # ortak pratik motoru + harita/bayrak modları + tur özeti
    settings/          # dil, istatistik sıfırlama, gizlilik/onay
  l10n/
assets/
  geo/countries.geo.bin   # (veya .json) sadeleştirilmiş sınır verisi
  data/countries.json     # ülke meta verisi
  flags/*.svg             # ISO kodlu bayraklar
tool/
  build_geo_data.dart     # ham GeoJSON → uygulama formatı dönüştürücü
docs/
  ROADMAP.md
  ATTRIBUTIONS.md         # veri/varlık lisansları
test/
```

**Kural:** `core/geo` ve pratik motorunun mantığı UI'dan bağımsız, saf Dart olmalı ve birim testleriyle doğrulanmalıdır.

---

## 4. Veri

### 4.1 Kaynaklar ve lisanslar
- **Sınırlar:** Natural Earth Admin-0 Countries, **1:50m** ölçeği (kamu malı). 1:110m küçük ülkeleri içermediği için kullanılmaz.
- **Bayraklar:** `lipis/flag-icons` SVG seti (MIT). Yalnızca ihtiyaç duyulan 4x3 SVG'ler kopyalanır.
- Tüm kaynaklar `docs/ATTRIBUTIONS.md` dosyasında ve uygulamanın Ayarlar > Hakkında bölümünde belirtilir.

### 4.2 Ülke kapsamı
- 193 BM üyesi + Vatikan + Filistin = **195**
- **Tartışmalı/kısmen tanınan ülkeler de dahil:** Kosova, Tayvan, KKTC, Batı Sahra (SADR), Somaliland, Abhazya, Güney Osetya. Kesin liste `countries.json` içinde `status` alanıyla tutulur.
- **Açık karar:** Kıbrıs/KKTC ve diğer tartışmalı sınırların çizimi. Natural Earth'ün varsayılan görüşü veya ülke görüşü (point-of-view) varyantlarından biri seçilecek. Karar verilmeden bu ülkelerin sınır verisi kesinleştirilmez. Karar verildiğinde bu satır güncellenmeli.

### 4.3 `countries.json` şeması
```json
{
  "id": "TR",              // ISO 3166-1 alpha-2; resmi kodu olmayanlarda özel kod (ör. "XK" Kosova, "NCY" KKTC)
  "iso3": "TUR",
  "name": { "tr": "Türkiye", "en": "Türkiye" },
  "capital": { "tr": "Ankara", "en": "Ankara" },
  "continent": "europe",   // africa | asia | europe | north_america | south_america | oceania
  "status": "un_member",   // un_member | observer | partially_recognized
  "difficulty": 1,          // 1 kolay, 2 orta, 3 zor
  "isTiny": false,          // küçük ülke işaretleme ve zorluk mantığı için
  "centroid": [39.0, 35.0], // [lat, lon], kameranın döneceği ve dairenin çizileceği nokta
  "flag": "tr.svg",
  "similarTo": ["AZ", "TN"] // benzer bayrak/komşu ülkeler (şık üretimi için ipucu)
}
```

Kıta ataması tutarlı olmalı. Türkiye ve Rusya gibi iki kıtalı ülkeler tek bir birincil kıtaya atanır (Türkiye → europe/asia kararı `countries.json` içinde sabitlenir). Zorluk etiketleri ilk aşamada nüfus, alan ve tanınırlığa göre elle/yarı otomatik belirlenir.

### 4.4 Geo veri hattı (`tool/build_geo_data.dart`)
1. Ham Natural Earth GeoJSON'u oku.
2. Mapshaper benzeri Douglas–Peucker sadeleştirmesi uygula. Hedef: tüm sınır verisi **< 1.5 MB**, görsel olarak düzgün.
3. Koordinatları Float32 kodlu kompakt bir formata yaz. Her ülke için çoklu poligon ve önceden hesaplanmış bounding box tutulur.
4. Çıktı `assets/geo/` altına yazılır. Ham veri repoya eklenmez (`.gitignore`).

---

## 5. Küre çizimi (en kritik teknik bölüm)

- **Yöntem:** Ortografik projeksiyon + `CustomPainter`. Küre bir daire, ülkeler bu dairenin içine projekte edilmiş poligonlar.
- **Rotasyon:** Merkez enlem/boylam (`centerLat`, `centerLon`) ile tutulur. Sürükleme hareketi bu değerleri değiştirir. Bırakınca hafif bir atalet (fling) animasyonu olur. Enlem ±90° ile sınırlanır.
- **Zoom:** Pinch ile ölçek 1.0–~40x arası. Yakın zoomda Vatikan ve Monako gibi ülkeler seçilebilir olmalı.
- **Görünürlük:** Arka yarıküredeki noktalar (merkez ile açısal mesafe > 90°) kırpılır. Ufuk çizgisinde poligonlar düzgün kesilmeli.
- **Performans:**
  - Görünmeyen ülkeleri önce bounding box testiyle ele.
  - Projeksiyonu her karede tüm noktalar için yeniden hesaplama, sadece görünür ülkeler için yap.
  - `Path` nesnelerini rotasyon değişmediği sürece önbelleğe al. `RepaintBoundary` kullan.
  - Hedef: orta segment Android cihazda sürükleme sırasında 60 fps.
- **Hit-test:** Dokunulan ekran noktasını ters projeksiyonla enlem/boylama çevir, sonra point-in-polygon ile ülkeyi bul. Küçük ülkeler için centroid'e yakınlık toleransı uygula.
- **Küçük ülkeler:** `isTiny: true` olan ülkeler vurgulandığında etrafına renkli bir daire çizilir. Harita pratiğinde kamera ülkeye döner ve uygun seviyeye yakınlaşır.
- **Animasyonlu odaklama:** `focusOn(countryId)` fonksiyonu küreyi centroid'e döndürür ve gerekirse yakınlaşır (harita pratiği ve bilgi kartı için ortak).

---

## 6. Pratik motoru

- Tur: **10 soru**. Tur sonunda skor özeti ve yanlış cevaplanan ülkelerin listesi gösterilir (listeden ülkeye dokununca bilgi kartı açılır).
- **Filtreler** (tur başlamadan seçilir):
  - Kıta: tümü veya bir/birden fazla kıta
  - Zorluk: kolay / orta / zor / karışık
  - Benzer şıklar: açıkken yanlış şıklar aynı kıtadan, komşu ülkelerden veya `similarTo` listesinden seçilir. Kapalıyken havuzdan rastgele seçilir.
- Bir turda aynı ülke iki kez sorulmaz. Şıklar karıştırılır ve şık listesinde tekrar olmaz.
- Filtre sonucu havuzda 10'dan az ülke kalırsa tur kısaltılır ve kullanıcıya bildirilir.
- Cevaptan sonra: doğru şık yeşil, yanlış seçilen kırmızı. "Devam" ile sonraki soruya geçilir (otomatik geçiş yok).
- Motor saf Dart'tır (`QuestionGenerator`, `RoundState`) ve rastgelelik testlerde sabitlenebilmesi için `Random` enjekte edilir.

---

## 7. İstatistik (yalnızca cihazda)

- Ülke ve mod bazında doğru/yanlış sayıları
- Mod ve filtre kombinasyonu başına en iyi tur skoru
- Toplam tamamlanan tur sayısı (reklam sıklığı da bunu kullanır)
- Ayarlar'dan "İstatistikleri sıfırla" seçeneği
- Hesap yok, veri cihazdan çıkmaz

---

## 8. Reklam politikası (kesin kurallar)

Amaç: gelir elde ederken kullanıcıyı kaçırmamak.

1. **Soru ekranlarında ve küre etkileşimi sırasında hiçbir reklam gösterilmez.**
2. **Banner:** Ana menü, bayrak listesi ve tur özeti ekranlarının altında tek adaptive banner. Küre ve pratik ekranlarında banner yok.
3. **Interstitial (tam ekran):** Yalnızca tur özeti ekranından çıkarken, **en fazla her 3 tamamlanmış turda bir**, ayrıca en az 3 dakika aralıkla. İlk oturumda hiç gösterilmez.
4. Reklam yüklenemezse akış asla bekletilmez veya bozulmaz.
5. Debug derlemelerde her zaman Google test reklam ID'leri kullanılır. Gerçek ID'ler `--dart-define` veya derleme yapılandırmasıyla verilir, koda yazılmaz.
6. AB/İngiltere kullanıcıları için uygulama açılışında UMP onay formu. Ayarlar'da "Gizlilik seçenekleri" butonu.
7. Çocuklara yönelik içerik olarak işaretlenecekse (Families politikası) reklam yapılandırması buna göre değişir. Hedef yaş kitlesi Play Console'da belirlenmeden önce bu konu netleştirilmeli.

---

## 9. Arayüz ve tasarım

- Material 3, açık ve koyu tema. Ana renk okyanus mavisi tonlarında.
- Ana menü: 4 büyük kart (Keşfet, Bayrakları Öğren, Harita Pratiği, Bayrak Pratiği) + ayarlar ikonu.
- Tüm metinler ARB dosyalarından gelir. Koda sabit Türkçe/İngilizce metin yazılmaz.
- Ülke adı sıralaması dile göre yapılır (Türkçe sıralamada Ç, Ğ, İ, Ö, Ş, Ü doğru konumda olmalı).
- Erişilebilirlik: dokunma hedefleri en az 48dp. Doğru/yanlış sadece renkle değil ikonla da belirtilir.

---

## 10. Kod kuralları

- `flutter analyze` uyarısız geçmeli. `very_good_analysis` veya `flutter_lints` kuralları uygulanır.
- Widget'lar küçük ve tek sorumlu. İş mantığı provider/servislerde.
- Geo matematiği ve pratik motoru için birim testi zorunlu.
- Commit mesajları İngilizce, Conventional Commits biçiminde (`feat:`, `fix:`, `refactor:` …).
- Bir aşama bitmeden diğerine geçme. Her aşama sonunda ROADMAP'teki kabul kriterlerini kontrol et ve işaretle.

## 11. Sık kullanılan komutlar

```bash
flutter pub get
flutter analyze
flutter test
dart run tool/build_geo_data.dart
flutter gen-l10n
flutter run --release
flutter build appbundle --release
```
