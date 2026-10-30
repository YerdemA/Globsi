# Yayın kontrol listesi

Kod tarafı hazır. Aşağıdakiler hesap, anahtar ya da karar gerektirdiği için
elle yapılır. Sıra önemli: 1–6 Play Console'dan önce.

## A. Play Console'dan önce

1. **Gizlilik politikasındaki iletişim e-postası**
   `assets/legal/privacy_tr.md` ve `privacy_en.md` içindeki
   `[İLETİŞİM E-POSTASI]` / `[CONTACT EMAIL]` yer tutucularını doldur, sonra:
   ```bash
   dart run tool/build_privacy_page.dart
   ```
2. **GitHub Pages**: Repo > Settings > Pages > "Deploy from a branch",
   `main` / `/docs`. Politika şu adreste açılmalı:
   <https://yerdema.github.io/Globsi/privacy-policy/>
   (`lib/app/app_info.dart` > `privacyPolicyUrl`)
3. **Yükleme anahtarı (upload key)** — bir kez oluştur, güvenli yerde yedekle:
   ```bash
   keytool -genkey -v -keystore C:/keys/globsi-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   `android/key.properties` (git'e girmez):
   ```properties
   storeFile=C:/keys/globsi-upload.jks
   storePassword=...
   keyAlias=upload
   keyPassword=...
   ```
4. **AdMob**: uygulamayı kaydet (Android, `com.yerdema.globsi`), bir banner ve
   bir interstitial reklam birimi oluştur.
5. **AdMob > Privacy & messaging**: AB/İngiltere için GDPR onay mesajı oluştur ve
   yayınla. Sonra debug'da dene:
   ```bash
   flutter run --dart-define=UMP_DEBUG_EEA=true
   ```
   Gerçek telefonda ayrıca `--dart-define=UMP_TEST_DEVICE=<hash>` gerekir (hash,
   logcat'te `UserMessagingPlatform` satırında yazar). Kendi formunu görmek için
   `-P ADMOB_APP_ID=ca-app-pub-...~...` da ver; yoksa Google'ın test uygulaması
   kullanılır.
   (`docs/ADS_TEST_CHECKLIST.md` kural 6)
6. **Release derlemesi** (README > Reklamlar):
   ```bash
   flutter build appbundle --release \
     -P ADMOB_APP_ID=ca-app-pub-...~... \
     --dart-define=ADMOB_BANNER_ID=ca-app-pub-.../... \
     --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-.../...
   ```
   Çıktı: `build/app/outputs/bundle/release/app-release.aab`.
   Gerçek bir telefonda dene (`flutter run --profile` ile sürükleme akıcılığını
   da ölç — ROADMAP Aşama 2'nin açık kabul maddesi).

## B. Play Console

7. **Uygulama oluştur**: ad "Globsi", varsayılan dil Türkçe, uygulama, ücretsiz.
8. **Mağaza sayfası**: `docs/store/listing_tr.md`, İngilizce çeviri olarak
   `listing_en.md`; simge, öne çıkan görsel ve ekran görüntüleri `docs/store/`.
9. **Uygulama içeriği**
   - Gizlilik politikası URL'si: adım 2'deki adres.
   - Reklamlar: **Evet, reklam içeriyor**.
   - Uygulama erişimi: tüm özellikler kısıtlamasız (giriş yok).
   - İçerik derecelendirmesi (IARC): şiddet, cinsellik, kumar, kullanıcı
     etkileşimi, konum paylaşımı yok → beklenen sonuç "Herkes / PEGI 3".
   - **Hedef kitle**: Karar "çocuklara yönelik değil" (CLAUDE.md §8). Öneri:
     **13+** yaş grupları (13–15, 16–17, 18+). 13 yaş altı seçilirse Families
     politikası devreye girer ve reklam yapılandırması değişmelidir.
     "Uygulama istemeden çocukların ilgisini çekebilir mi?" sorusunu dürüstçe
     yanıtla; "Evet" ise Google ek inceleme isteyebilir.
   - Haber uygulaması değil; COVID-19, finans, sağlık: hayır.
   - **Veri güvenliği**: aşağıdaki tablo.
10. **Kapalı test**: Test > Kapalı test > yeni kanal, test kullanıcılarının
    e-posta listesi, AAB'yi yükle, sürüm notu (aşağıda). Yeni kişisel geliştirici
    hesaplarında üretime çıkmadan önce **en az 12 test kullanıcısı ile 14 gün**
    kapalı test zorunlu olabilir; Play Console'daki güncel şartı kontrol et.
11. Kapalı testte gerçek cihazda baştan sona akış: Keşfet, bayrak listesi ve
    kartlar, iki pratik modu, istatistik, sıfırlama, dil değişimi, reklamlar.

### Veri güvenliği formu (Data safety)

Uygulamanın kendisi veri toplamaz; aşağıdakiler Google Mobile Ads SDK'sına aittir
(Google'ın AdMob için yayımladığı rehbere göre — formu doldururken güncel
rehberle karşılaştır).

| Soru | Cevap |
|---|---|
| Veri topluyor veya paylaşıyor musunuz? | Evet (reklam SDK'sı) |
| Aktarımda şifreleniyor mu? | Evet |
| Kullanıcı silme isteyebilir mi? | Uygulama kişisel veri saklamaz; yerel istatistikler uygulama içinden silinir |
| **Cihaz veya diğer kimlikler** (reklam kimliği) | Toplanır ve paylaşılır — Reklam/pazarlama, Analiz, Dolandırıcılık önleme |
| **Konum > Yaklaşık konum** (IP'den) | Toplanır ve paylaşılır — Reklam/pazarlama, Analiz, Dolandırıcılık önleme |
| **Uygulama etkinliği > Uygulama etkileşimleri** | Toplanır ve paylaşılır — Reklam/pazarlama, Analiz |
| **Uygulama bilgileri ve performans > Kilitlenme günlükleri, Teşhis** | Toplanır — Analiz |
| Ad, e-posta, kişiler, fotoğraf, finans vb. | Hayır |

`AndroidManifest`'e `AD_ID` izni Google Mobile Ads SDK'sı tarafından otomatik
eklenir; Play Console'da "Reklam kimliği" beyanında **Evet, reklam için** seç.

SDK, WorkManager üzerinden `FOREGROUND_SERVICE` iznini de ekler. Play Console bir
"ön plan hizmeti" beyanı isterse: uygulama kendisi ön plan hizmeti
kullanmaz; izin reklam SDK'sının arka plan işlerinden gelir.

### İlk sürüm notu (öneri)

```
tr: Globsi'nin ilk sürümü: küreyi keşfet, 202 ülkenin bayrağını öğren, harita ve bayrak pratiğiyle kendini sına.
en: First release of Globsi: explore the globe, learn the flags of 202 countries and test yourself with map and flag practice.
```
