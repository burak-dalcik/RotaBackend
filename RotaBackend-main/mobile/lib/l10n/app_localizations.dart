import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rota'**
  String get appTitle;

  /// No description provided for @navStops.
  ///
  /// In tr, this message translates to:
  /// **'Duraklar'**
  String get navStops;

  /// No description provided for @navAI.
  ///
  /// In tr, this message translates to:
  /// **'Yapay Zeka'**
  String get navAI;

  /// No description provided for @navSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get navSettings;

  /// No description provided for @navHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana sayfa'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get navSearch;

  /// No description provided for @navAlerts.
  ///
  /// In tr, this message translates to:
  /// **'Uyarılar'**
  String get navAlerts;

  /// No description provided for @navSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenler'**
  String get navSaved;

  /// No description provided for @homeHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki rotanı bul'**
  String get homeHeadline;

  /// No description provided for @homeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Durak listesi ve özet süreler sunucudan gelir; detayda yaklaşan seferler ve ML doluluk.'**
  String get homeSubtitle;

  /// No description provided for @searchHint.
  ///
  /// In tr, this message translates to:
  /// **'Durak kodu veya adı'**
  String get searchHint;

  /// No description provided for @stopsSection.
  ///
  /// In tr, this message translates to:
  /// **'Duraklar'**
  String get stopsSection;

  /// No description provided for @viewMap.
  ///
  /// In tr, this message translates to:
  /// **'HARİTAYI AÇ'**
  String get viewMap;

  /// No description provided for @stopsLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Duraklar yüklenemedi.'**
  String get stopsLoadError;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden dene'**
  String get retry;

  /// No description provided for @noStopsOnServer.
  ///
  /// In tr, this message translates to:
  /// **'Sunucuda kayıtlı durak yok.'**
  String get noStopsOnServer;

  /// No description provided for @noSearchMatch.
  ///
  /// In tr, this message translates to:
  /// **'Aramanızla eşleşen durak yok.'**
  String get noSearchMatch;

  /// No description provided for @stopRampOk.
  ///
  /// In tr, this message translates to:
  /// **'Durak rampası: uygun'**
  String get stopRampOk;

  /// No description provided for @stopRampNo.
  ///
  /// In tr, this message translates to:
  /// **'Durak rampası: yok / bilinmiyor'**
  String get stopRampNo;

  /// No description provided for @noTrip60.
  ///
  /// In tr, this message translates to:
  /// **'Önümüzdeki 60 dk içinde sefer yok'**
  String get noTrip60;

  /// No description provided for @minutesShort.
  ///
  /// In tr, this message translates to:
  /// **'dk'**
  String get minutesShort;

  /// No description provided for @mapLabel.
  ///
  /// In tr, this message translates to:
  /// **'HARİTA'**
  String get mapLabel;

  /// No description provided for @mapHint.
  ///
  /// In tr, this message translates to:
  /// **'Canlı harita için konum izni gerekir (yakında).'**
  String get mapHint;

  /// No description provided for @langSwitchToEnTooltip.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get langSwitchToEnTooltip;

  /// No description provided for @langSwitchToTrTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get langSwitchToTrTooltip;

  /// No description provided for @mlTooltipAbout.
  ///
  /// In tr, this message translates to:
  /// **'ML hakkında'**
  String get mlTooltipAbout;

  /// No description provided for @mlDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yapay zeka doluluk tahmini'**
  String get mlDialogTitle;

  /// No description provided for @mlDialogIntro.
  ///
  /// In tr, this message translates to:
  /// **'Rota, doluluk tahminini sunucunuzda çalışan XGBoost modeli ile üretir.'**
  String get mlDialogIntro;

  /// No description provided for @mlDialogFlow.
  ///
  /// In tr, this message translates to:
  /// **'Akış: Uygulama → Node API → Python ML köprüsü → .pkl modeli.'**
  String get mlDialogFlow;

  /// No description provided for @mlDialogCapacity.
  ///
  /// In tr, this message translates to:
  /// **'Bu ekrandaki yüzdeler, araç kapasitesine göre hesaplanır.'**
  String get mlDialogCapacity;

  /// No description provided for @mlServerOn.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu ML: açık'**
  String get mlServerOn;

  /// No description provided for @mlServerOff.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu ML: kapalı'**
  String get mlServerOff;

  /// No description provided for @mlStatusUnreadable.
  ///
  /// In tr, this message translates to:
  /// **'ML durumu şu an okunamadı (ağ veya sunucu).'**
  String get mlStatusUnreadable;

  /// No description provided for @ok.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// No description provided for @busesLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Otobüsler yüklenemedi.'**
  String get busesLoadError;

  /// No description provided for @noApproaching60.
  ///
  /// In tr, this message translates to:
  /// **'Önümüzdeki 60 dakikada yaklaşan otobüs yok.'**
  String get noApproaching60;

  /// No description provided for @refresh.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get refresh;

  /// No description provided for @pullRefreshHint.
  ///
  /// In tr, this message translates to:
  /// **'Tahminler sunucudaki ML modelinden gelir; aşağı çekerek yenileyin.'**
  String get pullRefreshHint;

  /// No description provided for @liveStatus.
  ///
  /// In tr, this message translates to:
  /// **'CANLI DURUM'**
  String get liveStatus;

  /// No description provided for @smartStopTitle.
  ///
  /// In tr, this message translates to:
  /// **'Akıllı durak'**
  String get smartStopTitle;

  /// No description provided for @comfortRoute.
  ///
  /// In tr, this message translates to:
  /// **'HAT'**
  String get comfortRoute;

  /// No description provided for @comfortMinutesAway.
  ///
  /// In tr, this message translates to:
  /// **'dakika içinde'**
  String get comfortMinutesAway;

  /// No description provided for @comfortMlLabel.
  ///
  /// In tr, this message translates to:
  /// **'YZ DOLULUK TAHMİNİ'**
  String get comfortMlLabel;

  /// No description provided for @comfortFullnessPercent.
  ///
  /// In tr, this message translates to:
  /// **'{percent}% dolu'**
  String comfortFullnessPercent(int percent);

  /// No description provided for @mlBannerDisabled.
  ///
  /// In tr, this message translates to:
  /// **'ML devre dışı — doluluk tahmini yedek modda üretiliyor.'**
  String get mlBannerDisabled;

  /// No description provided for @mlBannerBridgeDown.
  ///
  /// In tr, this message translates to:
  /// **'ML köprüsüne ulaşılamıyor — tahminler yedek modda olabilir.'**
  String get mlBannerBridgeDown;

  /// No description provided for @mlBannerModelsDown.
  ///
  /// In tr, this message translates to:
  /// **'ML modelleri yüklenemedi — tahminler yedek modda olabilir.'**
  String get mlBannerModelsDown;

  /// No description provided for @mlBannerLive.
  ///
  /// In tr, this message translates to:
  /// **'Doluluk tahmini yapay zeka modeli ile üretiliyor (XGBoost).'**
  String get mlBannerLive;

  /// No description provided for @mlBridgeDetail.
  ///
  /// In tr, this message translates to:
  /// **'Köprü: {detail}'**
  String mlBridgeDetail(String detail);

  /// No description provided for @iettRouteMapTitle.
  ///
  /// In tr, this message translates to:
  /// **'İETT güzergâh'**
  String get iettRouteMapTitle;

  /// No description provided for @comfortMlModelBadge.
  ///
  /// In tr, this message translates to:
  /// **'ML · XGBoost'**
  String get comfortMlModelBadge;

  /// No description provided for @comfortMlFallbackBadge.
  ///
  /// In tr, this message translates to:
  /// **'Yedek tahmin'**
  String get comfortMlFallbackBadge;

  /// No description provided for @comfortPaxEstimate.
  ///
  /// In tr, this message translates to:
  /// **'Tahmini yolcu: {pax} / {cap}'**
  String comfortPaxEstimate(int pax, int cap);

  /// No description provided for @mlDetailDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'ML Tahmin Detayı'**
  String get mlDetailDialogTitle;

  /// No description provided for @mlDetailRoute.
  ///
  /// In tr, this message translates to:
  /// **'Hat: {hatKodu} — {hatAdi}'**
  String mlDetailRoute(String hatKodu, String hatAdi);

  /// No description provided for @mlDetailCrowding.
  ///
  /// In tr, this message translates to:
  /// **'Doluluk: {percent}%'**
  String mlDetailCrowding(int percent);

  /// No description provided for @mlDetailSource.
  ///
  /// In tr, this message translates to:
  /// **'Kaynak: {source}'**
  String mlDetailSource(String source);

  /// No description provided for @mlDetailSourceModel.
  ///
  /// In tr, this message translates to:
  /// **'XGBoost Model Tahmini'**
  String get mlDetailSourceModel;

  /// No description provided for @mlDetailSourceFallback.
  ///
  /// In tr, this message translates to:
  /// **'Yedek Tahmin (Fallback)'**
  String get mlDetailSourceFallback;

  /// No description provided for @mlDetailArrival.
  ///
  /// In tr, this message translates to:
  /// **'Varış: {minutes} dakika'**
  String mlDetailArrival(int minutes);

  /// No description provided for @mlDetailAccessible.
  ///
  /// In tr, this message translates to:
  /// **'Engelli erişimi: {status}'**
  String mlDetailAccessible(String status);

  /// No description provided for @mlDetailAccessibleYes.
  ///
  /// In tr, this message translates to:
  /// **'Uygun'**
  String get mlDetailAccessibleYes;

  /// No description provided for @mlDetailAccessibleNo.
  ///
  /// In tr, this message translates to:
  /// **'Uygun değil'**
  String get mlDetailAccessibleNo;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @mlDashTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yapay Zeka Paneli'**
  String get mlDashTitle;

  /// No description provided for @mlDashModelName.
  ///
  /// In tr, this message translates to:
  /// **'XGBoost Regressor'**
  String get mlDashModelName;

  /// No description provided for @mlDashModelDesc.
  ///
  /// In tr, this message translates to:
  /// **'Doluluk tahmini için eğitilmiş makine öğrenmesi modeli.'**
  String get mlDashModelDesc;

  /// No description provided for @mlDashFeatures.
  ///
  /// In tr, this message translates to:
  /// **'Özellikler: Saat, Hafta sonu, Resmi tatil, Hat kodu, Kapasite'**
  String get mlDashFeatures;

  /// No description provided for @mlDashPipeline.
  ///
  /// In tr, this message translates to:
  /// **'Veri Akışı'**
  String get mlDashPipeline;

  /// No description provided for @mlDashStep1.
  ///
  /// In tr, this message translates to:
  /// **'Flutter uygulama istek gönderir'**
  String get mlDashStep1;

  /// No description provided for @mlDashStep2.
  ///
  /// In tr, this message translates to:
  /// **'Node.js API isteği iletir'**
  String get mlDashStep2;

  /// No description provided for @mlDashStep3.
  ///
  /// In tr, this message translates to:
  /// **'Python FastAPI modeli çalıştırır'**
  String get mlDashStep3;

  /// No description provided for @mlDashStep4.
  ///
  /// In tr, this message translates to:
  /// **'XGBoost tahmin üretir'**
  String get mlDashStep4;

  /// No description provided for @mlDashBridgeStatus.
  ///
  /// In tr, this message translates to:
  /// **'Köprü Durumu'**
  String get mlDashBridgeStatus;

  /// No description provided for @mlDashConnected.
  ///
  /// In tr, this message translates to:
  /// **'Bağlı'**
  String get mlDashConnected;

  /// No description provided for @mlDashDisconnected.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı yok'**
  String get mlDashDisconnected;

  /// No description provided for @mlDashModelLoaded.
  ///
  /// In tr, this message translates to:
  /// **'Model Yüklü'**
  String get mlDashModelLoaded;

  /// No description provided for @mlDashModelNotLoaded.
  ///
  /// In tr, this message translates to:
  /// **'Model Yüklenemedi'**
  String get mlDashModelNotLoaded;

  /// No description provided for @mlDashCheckNow.
  ///
  /// In tr, this message translates to:
  /// **'Durumu kontrol et'**
  String get mlDashCheckNow;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDesc.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama arayüz dilini değiştir'**
  String get settingsLanguageDesc;

  /// No description provided for @settingsTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get settingsTurkish;

  /// No description provided for @settingsEnglish.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get settingsEnglish;

  /// No description provided for @settingsApiEndpoint.
  ///
  /// In tr, this message translates to:
  /// **'API Adresi'**
  String get settingsApiEndpoint;

  /// No description provided for @settingsAbout.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get settingsAbout;

  /// No description provided for @settingsAboutDesc.
  ///
  /// In tr, this message translates to:
  /// **'Rota — İstanbul toplu taşıma yapay zeka doluluk tahmin uygulaması. tech.istanbul Datathon 2026 projesi.'**
  String get settingsAboutDesc;

  /// No description provided for @settingsVersion.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm'**
  String get settingsVersion;

  /// No description provided for @mlStatusActive.
  ///
  /// In tr, this message translates to:
  /// **'YZ Aktif'**
  String get mlStatusActive;

  /// No description provided for @mlStatusInactive.
  ///
  /// In tr, this message translates to:
  /// **'YZ Pasif'**
  String get mlStatusInactive;

  /// No description provided for @navMap.
  ///
  /// In tr, this message translates to:
  /// **'Harita'**
  String get navMap;

  /// No description provided for @mapNearestStop.
  ///
  /// In tr, this message translates to:
  /// **'En Yakın Durak'**
  String get mapNearestStop;

  /// No description provided for @mapLocationServiceOff.
  ///
  /// In tr, this message translates to:
  /// **'Konum servisi kapalı. Lütfen ayarlardan açın.'**
  String get mapLocationServiceOff;

  /// No description provided for @mapLocationDenied.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni reddedildi.'**
  String get mapLocationDenied;

  /// No description provided for @mapLocationDeniedForever.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni kalıcı olarak reddedildi. Ayarlardan izin verin.'**
  String get mapLocationDeniedForever;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
