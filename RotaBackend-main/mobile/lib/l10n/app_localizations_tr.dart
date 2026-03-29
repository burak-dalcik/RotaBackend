// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Rota';

  @override
  String get navStops => 'Duraklar';

  @override
  String get navAI => 'Yapay Zeka';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get navHome => 'Ana sayfa';

  @override
  String get navSearch => 'Ara';

  @override
  String get navAlerts => 'Uyarılar';

  @override
  String get navSaved => 'Kaydedilenler';

  @override
  String get homeHeadline => 'Sonraki rotanı bul';

  @override
  String get homeSubtitle =>
      'Durak listesi ve özet süreler sunucudan gelir; detayda yaklaşan seferler ve ML doluluk.';

  @override
  String get searchHint => 'Durak kodu veya adı';

  @override
  String get stopsSection => 'Duraklar';

  @override
  String get viewMap => 'HARİTAYI AÇ';

  @override
  String get stopsLoadError => 'Duraklar yüklenemedi.';

  @override
  String get retry => 'Yeniden dene';

  @override
  String get noStopsOnServer => 'Sunucuda kayıtlı durak yok.';

  @override
  String get noSearchMatch => 'Aramanızla eşleşen durak yok.';

  @override
  String get stopRampOk => 'Durak rampası: uygun';

  @override
  String get stopRampNo => 'Durak rampası: yok / bilinmiyor';

  @override
  String get noTrip60 => 'Önümüzdeki 60 dk içinde sefer yok';

  @override
  String get minutesShort => 'dk';

  @override
  String get mapLabel => 'HARİTA';

  @override
  String get mapHint => 'Canlı harita için konum izni gerekir (yakında).';

  @override
  String get langSwitchToEnTooltip => 'İngilizce';

  @override
  String get langSwitchToTrTooltip => 'Türkçe';

  @override
  String get mlTooltipAbout => 'ML hakkında';

  @override
  String get mlDialogTitle => 'Yapay zeka doluluk tahmini';

  @override
  String get mlDialogIntro =>
      'Rota, doluluk tahminini sunucunuzda çalışan XGBoost modeli ile üretir.';

  @override
  String get mlDialogFlow =>
      'Akış: Uygulama → Node API → Python ML köprüsü → .pkl modeli.';

  @override
  String get mlDialogCapacity =>
      'Bu ekrandaki yüzdeler, araç kapasitesine göre hesaplanır.';

  @override
  String get mlServerOn => 'Sunucu ML: açık';

  @override
  String get mlServerOff => 'Sunucu ML: kapalı';

  @override
  String get mlStatusUnreadable =>
      'ML durumu şu an okunamadı (ağ veya sunucu).';

  @override
  String get ok => 'Tamam';

  @override
  String get busesLoadError => 'Otobüsler yüklenemedi.';

  @override
  String get noApproaching60 => 'Önümüzdeki 60 dakikada yaklaşan otobüs yok.';

  @override
  String get refresh => 'Yenile';

  @override
  String get pullRefreshHint =>
      'Tahminler sunucudaki ML modelinden gelir; aşağı çekerek yenileyin.';

  @override
  String get liveStatus => 'CANLI DURUM';

  @override
  String get smartStopTitle => 'Akıllı durak';

  @override
  String get comfortRoute => 'HAT';

  @override
  String get comfortMinutesAway => 'dakika içinde';

  @override
  String get comfortMlLabel => 'YZ DOLULUK TAHMİNİ';

  @override
  String comfortFullnessPercent(int percent) {
    return '$percent% dolu';
  }

  @override
  String get mlBannerDisabled =>
      'ML devre dışı — doluluk tahmini yedek modda üretiliyor.';

  @override
  String get mlBannerBridgeDown =>
      'ML köprüsüne ulaşılamıyor — tahminler yedek modda olabilir.';

  @override
  String get mlBannerModelsDown =>
      'ML modelleri yüklenemedi — tahminler yedek modda olabilir.';

  @override
  String get mlBannerLive =>
      'Doluluk tahmini yapay zeka modeli ile üretiliyor (XGBoost).';

  @override
  String mlBridgeDetail(String detail) {
    return 'Köprü: $detail';
  }

  @override
  String get iettRouteMapTitle => 'İETT güzergâh';

  @override
  String get comfortMlModelBadge => 'ML · XGBoost';

  @override
  String get comfortMlFallbackBadge => 'Yedek tahmin';

  @override
  String comfortPaxEstimate(int pax, int cap) {
    return 'Tahmini yolcu: $pax / $cap';
  }

  @override
  String get mlDetailDialogTitle => 'ML Tahmin Detayı';

  @override
  String mlDetailRoute(String hatKodu, String hatAdi) {
    return 'Hat: $hatKodu — $hatAdi';
  }

  @override
  String mlDetailCrowding(int percent) {
    return 'Doluluk: $percent%';
  }

  @override
  String mlDetailSource(String source) {
    return 'Kaynak: $source';
  }

  @override
  String get mlDetailSourceModel => 'XGBoost Model Tahmini';

  @override
  String get mlDetailSourceFallback => 'Yedek Tahmin (Fallback)';

  @override
  String mlDetailArrival(int minutes) {
    return 'Varış: $minutes dakika';
  }

  @override
  String mlDetailAccessible(String status) {
    return 'Engelli erişimi: $status';
  }

  @override
  String get mlDetailAccessibleYes => 'Uygun';

  @override
  String get mlDetailAccessibleNo => 'Uygun değil';

  @override
  String get close => 'Kapat';

  @override
  String get mlDashTitle => 'Yapay Zeka Paneli';

  @override
  String get mlDashModelName => 'XGBoost Regressor';

  @override
  String get mlDashModelDesc =>
      'Doluluk tahmini için eğitilmiş makine öğrenmesi modeli.';

  @override
  String get mlDashFeatures =>
      'Özellikler: Saat, Hafta sonu, Resmi tatil, Hat kodu, Kapasite';

  @override
  String get mlDashPipeline => 'Veri Akışı';

  @override
  String get mlDashStep1 => 'Flutter uygulama istek gönderir';

  @override
  String get mlDashStep2 => 'Node.js API isteği iletir';

  @override
  String get mlDashStep3 => 'Python FastAPI modeli çalıştırır';

  @override
  String get mlDashStep4 => 'XGBoost tahmin üretir';

  @override
  String get mlDashBridgeStatus => 'Köprü Durumu';

  @override
  String get mlDashConnected => 'Bağlı';

  @override
  String get mlDashDisconnected => 'Bağlantı yok';

  @override
  String get mlDashModelLoaded => 'Model Yüklü';

  @override
  String get mlDashModelNotLoaded => 'Model Yüklenemedi';

  @override
  String get mlDashCheckNow => 'Durumu kontrol et';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLanguageDesc => 'Uygulama arayüz dilini değiştir';

  @override
  String get settingsTurkish => 'Türkçe';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsApiEndpoint => 'API Adresi';

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get settingsAboutDesc =>
      'Rota — İstanbul toplu taşıma yapay zeka doluluk tahmin uygulaması. tech.istanbul Datathon 2026 projesi.';

  @override
  String get settingsVersion => 'Sürüm';

  @override
  String get mlStatusActive => 'YZ Aktif';

  @override
  String get mlStatusInactive => 'YZ Pasif';

  @override
  String get navMap => 'Harita';

  @override
  String get mapNearestStop => 'En Yakın Durak';

  @override
  String get mapLocationServiceOff =>
      'Konum servisi kapalı. Lütfen ayarlardan açın.';

  @override
  String get mapLocationDenied => 'Konum izni reddedildi.';

  @override
  String get mapLocationDeniedForever =>
      'Konum izni kalıcı olarak reddedildi. Ayarlardan izin verin.';
}
