# Reklam kuralları — manuel test listesi

`CLAUDE.md` §8'deki her kuralın nasıl doğrulandığı. Otomatik testler:
`test/core/ads/interstitial_policy_test.dart`,
`test/features/ads_placement_test.dart`.

Emülatör testleri 2026-10-29'da Pixel 6 (Android 16) emülatöründe, Google test
reklam birimleriyle yapıldı. Interstitial'ı elle tetiklemek için:

```bash
flutter run --dart-define=ADS_DEBUG_FREQUENT=true
```

Bu bayrak yalnızca debug'da çalışır; tur (5) ve süre (10 dk) sınırlarını
kaldırır, **ilk oturum** ve **oturum başına 1** kurallarını korur. Oturum
sayacını sıfırlamak için: `adb shell pm clear com.yerdema.globsi`.

| # | Kural | Nasıl doğrulandı | Sonuç |
|---|---|---|---|
| 1 | Soru ekranlarında ve küre etkileşiminde reklam yok | Bayrak ve harita turlarında 10 soru boyunca ekran görüntüsü; Keşfet ekranı. Otomatik: her soruda banner yok, Keşfet'te banner yok | ✅ |
| 2 | Banner yalnızca ana menü, bayrak listesi, tur özeti; tek banner, ≤ 60 dp | Ana menü ve özet ekranında test banner'ı göründü; Kartlar sekmesinde, filtre ekranında ve sorularda yok. Otomatik test aynı yerleşimi kontrol ediyor | ✅ |
| 3a | Interstitial yalnızca özetten çıkarken | "Ana menü"ye basınca test interstitial'ı açıldı (`AdActivity` en üstte); başka hiçbir geçişte çağrılmıyor. Otomatik: `onLeaveSummary` yalnızca özetten çıkışta | ✅ |
| 3b | İlk oturumda hiç yok | `pm clear` sonrası ilk açılışta tur bitti, özetten çıkıldı → reklam yok (`MainActivity` üstte) | ✅ |
| 3c | Oturum başına en fazla 1 | Aynı oturumda ikinci tur → `allowed=false`, reklam yok | ✅ |
| 3d | En az 5 tur ve 10 dakika arayla | Birim testleri (sınır değerleri dahil). Elle: bayraksız çalıştırmada 3. oturum / 3. turda `allowed=false` | ✅ |
| 4 | Reklam yüklenemezse akış bekletilmez/bozulmaz | Wi-Fi ve mobil veri kapalıyken uygulama açıldı, banner alanı boş kaldı (yer kaplamadı), tur ve özet sorunsuz. Otomatik: her çağrıda hata fırlatan sahte servisle tam tur + "Tekrar oyna" | ✅ |
| 5 | Debug'da test ID'leri, gerçek ID'ler koda yazılmaz | `AdConfig`: debug/profile her zaman test birimi; release `--dart-define`'dan okur, yoksa reklam kapalı. App ID `-PADMOB_APP_ID` ile | ✅ |
| 6 | AB/İngiltere için UMP formu, Ayarlar'da "Gizlilik seçenekleri" | Kod hazır (`GoogleAdService.initialize`, Ayarlar'da yalnızca gerekliyse görünen satır). **Form, AdMob'da gerçek uygulama ve "Privacy & messaging" mesajı yayınlanınca test edilmeli:** `flutter run --dart-define=UMP_DEBUG_EEA=true` | ⏳ AdMob kaydı bekliyor |
| 7 | Çocuklara yönelik değil; içerik PG | `RequestConfiguration(maxAdContentRating: PG)`; `tagForChildDirectedTreatment` kullanılmıyor | ✅ |

## Yayından önce gerçek ID'lerle tekrar

- [ ] Gerçek app ID ve birim ID'leriyle release derlemesi (README) — banner ve
      interstitial dolu geliyor mu?
- [ ] AB konumlu test (`UMP_DEBUG_EEA=true`, debug) — onay formu açılıyor,
      reddedince reklam istenmiyor, Ayarlar'da "Gizlilik seçenekleri" görünüyor.
- [ ] Gerçek reklamlara kendin tıklama (AdMob hesabı kısıtlanabilir); test
      cihazını AdMob'a ekle.
