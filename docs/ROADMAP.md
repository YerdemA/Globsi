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
- [x] Saf Dart `QuestionGenerator` + `RoundState` (enjekte edilebilir `Random`)
- [x] Filtre ekranı: kıta (çoklu), zorluk, benzer şıklar anahtarı
- [x] Bayrak pratiği ekranı
- [x] Harita pratiği ekranı (küre widget'ının etkileşimsiz/yarı etkileşimli modu, `focusOn` ile)
- [x] Cevap geri bildirimi (renk + ikon), "Devam" butonu
- [x] Tur özeti: skor, yanlışlar listesi, "Tekrar oyna" / "Ana menü"
- [x] Birim testleri: tekrar yok, doğru şık her zaman var, filtre uyumu, küçük havuz davranışı

**Kabul:** Her filtre kombinasyonunda 10 soruluk tur sorunsuz tamamlanıyor. Motor testleri geçiyor.

---

## Aşama 5 — Yerel istatistik
- [x] `StatsService`: ülke × mod doğru/yanlış, en iyi skorlar, toplam tur
- [x] Tur sonunda kayıt
- [x] Basit istatistik ekranı (genel doğruluk oranı, en çok karıştırılan ülkeler)
- [x] Ayarlar: istatistikleri sıfırla (onaylı)

**Kabul:** Uygulama kapanıp açılınca veriler korunuyor, sıfırlama çalışıyor.

---

## Aşama 6 — Reklamlar
- [ ] AdMob uygulama kaydı (Erdem yapacak) — kod tarafı hazır: ID'ler `--dart-define` ve `-PADMOB_APP_ID` ile veriliyor
- [x] UMP onay akışı + Ayarlar'da "Gizlilik seçenekleri"
- [x] `AdService`: banner yerleşimleri ve interstitial sıklık kuralları (`CLAUDE.md` §8)
- [x] Debug'da test ID'leri
- [x] Reklam yüklenemediğinde akışın bozulmadığının testi

**Kabul:** §8'deki tüm kurallar manuel test listesinde tek tek doğrulanmış.

---

## Aşama 7 — Cilalama ve yayın hazırlığı
- [x] Uygulama ikonu ve açılış ekranı (adaptif + temalı ikon, Android 12 splash)
- [x] Ayarlar > Hakkında: sürüm, lisanslar, gizlilik politikası (uygulama içi)
- [x] Gizlilik politikası sayfası (AdMob nedeniyle zorunlu) — `docs/privacy-policy/`; iletişim e-postası ve GitHub Pages elle (`docs/RELEASE_CHECKLIST.md`)
- [x] `flutter build appbundle --release`, R8/küçültme açık, APK/AAB boyutu kontrolü (arm64 APK 23 MB)
- [ ] Play Console: mağaza açıklaması TR/EN, ekran görüntüleri, veri güvenliği formu (reklam kimliği), hedef kitle beyanı — materyaller hazır (`docs/store/`, `docs/RELEASE_CHECKLIST.md`), girişler elle
- [ ] Kapalı test sürümü

**Kabul:** Kapalı test kanalına yüklendi, gerçek cihazda baştan sona akış hatasız.

---

## Sonraki sürümler için fikir havuzu

### Uygulamanın geliştirilebilir yönleri
1. **Gerçek cihazda performans:** Küredeki akıcılık yalnızca bilgisayarda ölçüldü (kare başına ≤ 4 ms). Orta segment bir telefonda ölçülmeli; yetmezse çizim yöntemi hızlandırılabilir.
2. **Bayrak boyutu:** Bayraklar APK'da 1,3 MB, bunun 287 KB'ı yalnızca Sırbistan'ın arması. En büyük 10–15 bayrak sadeleştirilirse yarıya iner.
3. **Tablet ve yatay ekran:** Arayüz dikey telefona göre tasarlandı. Geniş ekranda pratikte küre ve şıklar yan yana, bayrak listesi daha çok sütunlu olabilir.
4. **Yakınlaştırma:** İki parmakla yakınlaştırma şu an ekranın merkezine göre çalışıyor. Parmakların arasındaki noktaya göre olması daha doğal hissettirir.
5. **Erişilebilirlik:** Ekran okuyucuyla (TalkBack) küreden ülke seçilemiyor. Bir "listeden seç" alternatifi, büyük yazı boyutunda kontrol ve koyu tema kontrast kontrolü yapılmalı; koyu tema hiç test edilmedi.
6. **Küçük kullanım iyileştirmeleri:**
   - Pratik filtrelerinin hatırlanması
   - Kart destesinin karışık başlaması (şu an hep Abhazya ile başlıyor)
   - "Tekrar oyna"nın aynı yanlışlara ağırlık vermesi
7. **Zorluk etiketleri:** İlk elden kabaca dağıtıldı. Kendi istatistiklerle ya da test kullanıcılarının sonuçlarıyla güncellenmeli.

### Eklenebilir özellikler

**Hızlı kazanımlar (veri ve altyapı hazır):**
- **Başkent pratiği:** Başkentler `countries.json` içinde zaten var; mevcut motorda yeni bir mod olarak eklenir.
- **"Haritada bul" modu:** Ülke adı verilir, kullanıcı küreye dokunur. Dokunma algılama hazır.
- **Akıllı tekrar:** Sık yanlış yapılan ülkeleri daha sık sorma. İstatistikler zaten tutuluyor.
- **Kürede ülke arama.**
- **Günlük meydan okuma:** Tarihten türetilen sabit bir rastgelelik ile herkese aynı 10 soru, internet gerekmeden.

**Orta vadeli:**
- Yeni soru tipleri: addan bayrak seçme, "hangisi komşusu değil?", kıta sorusu.
- Seri (streak) ve rozetler (cihazda).
- Ülke kartına nüfus, yüzölçümü, para birimi ve dil eklenmesi.
- Ana ekran widget'ı: "Günün bayrağı".

**Uzun vadeli (v1 kapsamı dışı):** iOS, reklamsız sürüm için tek seferlik satın alma, ülke adlarının sesli telaffuzu.
