# Globsi — Geliştirme Yol Haritası

Her aşama, bir öncekinin kabul kriterleri sağlandıktan sonra başlar. Tamamlanan maddeleri `[x]` ile işaretle.

---

## Aşama 0 — Proje kurulumu
- [x] `flutter create --org com.yerdema --project-name globsi --platforms android .`
- [x] Paketler: flutter_riverpod, go_router, flutter_svg, shared_preferences, intl, flutter_localizations, google_mobile_ads
- [x] Lint kuralları, `analysis_options.yaml`
- [x] `CLAUDE.md` ile uyumlu klasör yapısı
- [x] TR/EN ARB dosyaları ve `flutter gen-l10n` kurulumu
- [x] Tema (açık/koyu), go_router ile boş 4 ekranlı ana menü
- [x] `.gitignore`: ham geo verisi, build çıktıları, keystore

**Kabul:** Uygulama açılıyor, ana menüden 4 boş ekrana gidiliyor, dil değişince menü metinleri değişiyor, `flutter analyze` temiz.

---

## Aşama 1 — Veri hattı
- [x] Natural Earth 1:50m Admin-0 indirme talimatı (README'ye)
- [x] `tool/build_geo_data.dart`: sadeleştirme + kompakt ikili format + bounding box
- [x] `assets/data/countries.json`: 195 + tartışmalı ülkeler, TR/EN ad ve başkent, kıta, durum, zorluk, `isTiny`, centroid, `similarTo`
- [x] Gerekli bayrak SVG'lerinin kopyalanması (flag-icons, MIT)
- [x] `docs/ATTRIBUTIONS.md`
- [x] Veri doğrulama testi: her ülkenin geo verisi, bayrağı ve her iki dilde adı var, kodlar benzersiz
- [x] Repository katmanı: `CountryRepository` (meta + geo yükleme, önbellek)

**Kabul:** Doğrulama testi geçiyor, geo varlığı 1.5 MB altında, KKTC/Kıbrıs sınır kararı `CLAUDE.md` içine yazılmış.

---

## Aşama 2 — Küre (Keşfet)
- [x] `core/geo`: ortografik projeksiyon, ters projeksiyon, ufuk kırpma, point-in-polygon (birim testli)
- [x] `GlobePainter`: okyanus, ülke dolguları, sınır çizgileri, vurgulanan ülke, küçük ülke dairesi
- [x] Sürükleyerek döndürme + atalet, pinch zoom, sınır değerleri
- [x] Dokunarak ülke seçme → bilgi kartı (ad, bayrak, başkent, kıta)
- [x] `focusOn(countryId)` animasyonu
- [x] Performans: bounding box eleme, Path önbelleği, RepaintBoundary

**Kabul:** Gerçek bir orta segment Android cihazda sürükleme akıcı (profil modunda ölçülmüş). Vatikan ve Monako yakın zoomda seçilebiliyor. Arka yüzdeki ülkeler görünmüyor, ufukta kırpma düzgün.

> Durum (2026-10-28): Vatikan/Monako seçimi, arka yüz ve ufuk kırpma emülatörde ve testlerde doğrulandı. **Gerçek cihazda profil modu ölçümü henüz yapılmadı** (bkz. `flutter run --profile`). Masaüstü ölçümünde kare başına yol üretimi tüm zoom aralığında ≤ 4 ms.

---

## Aşama 3 — Bayrak öğrenme modu
- [x] Kıtaya göre gruplu ızgara, dile göre doğru alfabetik sıralama
- [x] Bayrak detay ekranı/kartı
- [x] Kart çevirme görünümü: çevirme animasyonu, kaydırarak geçiş, kıta seçimi, karıştır
- [x] Detaydan "Kürede göster" → Keşfet ekranında `focusOn`

**Kabul:** Tüm bayraklar doğru ülkeyle eşleşiyor, liste kaydırması takılmıyor (SVG önbellek), kart modu tek elle rahat kullanılıyor.

---

## Aşama 4 — Pratik motoru ve modlar
- [ ] Saf Dart `QuestionGenerator` + `RoundState` (enjekte edilebilir `Random`)
- [ ] Filtre ekranı: kıta (çoklu), zorluk, benzer şıklar anahtarı
- [ ] Bayrak pratiği ekranı
- [ ] Harita pratiği ekranı (küre widget'ının etkileşimsiz/yarı etkileşimli modu, `focusOn` ile)
- [ ] Cevap geri bildirimi (renk + ikon), "Devam" butonu
- [ ] Tur özeti: skor, yanlışlar listesi, "Tekrar oyna" / "Ana menü"
- [ ] Birim testleri: tekrar yok, doğru şık her zaman var, filtre uyumu, küçük havuz davranışı

**Kabul:** Her filtre kombinasyonunda 10 soruluk tur sorunsuz tamamlanıyor. Motor testleri geçiyor.

---

## Aşama 5 — Yerel istatistik
- [ ] `StatsService`: ülke × mod doğru/yanlış, en iyi skorlar, toplam tur
- [ ] Tur sonunda kayıt
- [ ] Basit istatistik ekranı (genel doğruluk oranı, en çok karıştırılan ülkeler)
- [ ] Ayarlar: istatistikleri sıfırla (onaylı)

**Kabul:** Uygulama kapanıp açılınca veriler korunuyor, sıfırlama çalışıyor.

---

## Aşama 6 — Reklamlar
- [ ] AdMob uygulama kaydı (Erdem yapacak), ID'lerin `--dart-define` ile verilmesi
- [ ] UMP onay akışı + Ayarlar'da "Gizlilik seçenekleri"
- [ ] `AdService`: banner yerleşimleri ve interstitial sıklık kuralları (`CLAUDE.md` §8)
- [ ] Debug'da test ID'leri
- [ ] Reklam yüklenemediğinde akışın bozulmadığının testi

**Kabul:** §8'deki tüm kurallar manuel test listesinde tek tek doğrulanmış.

---

## Aşama 7 — Cilalama ve yayın hazırlığı
- [ ] Uygulama ikonu ve açılış ekranı
- [ ] Ayarlar > Hakkında: sürüm, lisanslar, gizlilik politikası bağlantısı
- [ ] Gizlilik politikası sayfası (AdMob nedeniyle zorunlu)
- [ ] `flutter build appbundle --release`, R8/küçültme açık, APK/AAB boyutu kontrolü
- [ ] Play Console: mağaza açıklaması TR/EN, ekran görüntüleri, veri güvenliği formu (reklam kimliği), hedef kitle beyanı
- [ ] Kapalı test sürümü

**Kabul:** Kapalı test kanalına yüklendi, gerçek cihazda baştan sona akış hatasız.

---

## Sonraki sürümler için fikir havuzu
- Akıllı tekrar (sık yanlış yapılan ülkeleri daha sık sorma)
- Başkent pratiği
- Kürede ülke arama
- Günlük meydan okuma
- iOS
