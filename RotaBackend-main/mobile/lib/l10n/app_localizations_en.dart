// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Rota';

  @override
  String get navStops => 'Stops';

  @override
  String get navAI => 'AI Model';

  @override
  String get navSettings => 'Settings';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navSaved => 'Saved';

  @override
  String get homeHeadline => 'Find your next path';

  @override
  String get homeSubtitle =>
      'Stop list and ETA previews come from the server; stop detail shows approaching trips and ML crowding.';

  @override
  String get searchHint => 'Stop code or name';

  @override
  String get stopsSection => 'Stops';

  @override
  String get viewMap => 'VIEW MAP';

  @override
  String get stopsLoadError => 'Could not load stops.';

  @override
  String get retry => 'Try again';

  @override
  String get noStopsOnServer => 'No stops registered on the server.';

  @override
  String get noSearchMatch => 'No stops match your search.';

  @override
  String get stopRampOk => 'Stop ramp: available';

  @override
  String get stopRampNo => 'Stop ramp: none / unknown';

  @override
  String get noTrip60 => 'No trip in the next 60 min';

  @override
  String get minutesShort => 'min';

  @override
  String get mapLabel => 'MAP';

  @override
  String get mapHint =>
      'Location permission required for live map (coming soon).';

  @override
  String get langSwitchToEnTooltip => 'English';

  @override
  String get langSwitchToTrTooltip => 'Turkish';

  @override
  String get mlTooltipAbout => 'About ML';

  @override
  String get mlDialogTitle => 'AI crowding estimate';

  @override
  String get mlDialogIntro =>
      'Rota estimates crowding with an XGBoost model running on your server.';

  @override
  String get mlDialogFlow =>
      'Flow: App → Node API → Python ML bridge → .pkl model.';

  @override
  String get mlDialogCapacity =>
      'Percentages on this screen are based on vehicle capacity.';

  @override
  String get mlServerOn => 'Server ML: on';

  @override
  String get mlServerOff => 'Server ML: off';

  @override
  String get mlStatusUnreadable =>
      'ML status could not be read (network or server).';

  @override
  String get ok => 'OK';

  @override
  String get busesLoadError => 'Could not load buses.';

  @override
  String get noApproaching60 => 'No buses approaching in the next 60 minutes.';

  @override
  String get refresh => 'Refresh';

  @override
  String get pullRefreshHint =>
      'Predictions come from the server ML model; pull down to refresh.';

  @override
  String get liveStatus => 'LIVE';

  @override
  String get smartStopTitle => 'Smart stop';

  @override
  String get comfortRoute => 'ROUTE';

  @override
  String get comfortMinutesAway => 'minutes away';

  @override
  String get comfortMlLabel => 'AI CROWDING ESTIMATE';

  @override
  String comfortFullnessPercent(int percent) {
    return '$percent% full';
  }

  @override
  String get mlBannerDisabled => 'ML is off — crowding uses fallback mode.';

  @override
  String get mlBannerBridgeDown =>
      'Cannot reach ML bridge — estimates may use fallback.';

  @override
  String get mlBannerModelsDown =>
      'ML models failed to load — estimates may use fallback.';

  @override
  String get mlBannerLive => 'Crowding estimate from the AI model (XGBoost).';

  @override
  String mlBridgeDetail(String detail) {
    return 'Bridge: $detail';
  }

  @override
  String get iettRouteMapTitle => 'IETT route';

  @override
  String get comfortMlModelBadge => 'ML · XGBoost';

  @override
  String get comfortMlFallbackBadge => 'Fallback estimate';

  @override
  String comfortPaxEstimate(int pax, int cap) {
    return 'Est. passengers: $pax / $cap';
  }

  @override
  String get mlDetailDialogTitle => 'ML Prediction Detail';

  @override
  String mlDetailRoute(String hatKodu, String hatAdi) {
    return 'Route: $hatKodu — $hatAdi';
  }

  @override
  String mlDetailCrowding(int percent) {
    return 'Crowding: $percent%';
  }

  @override
  String mlDetailSource(String source) {
    return 'Source: $source';
  }

  @override
  String get mlDetailSourceModel => 'XGBoost Model Prediction';

  @override
  String get mlDetailSourceFallback => 'Fallback Estimate';

  @override
  String mlDetailArrival(int minutes) {
    return 'Arrival: $minutes minutes';
  }

  @override
  String mlDetailAccessible(String status) {
    return 'Accessibility: $status';
  }

  @override
  String get mlDetailAccessibleYes => 'Available';

  @override
  String get mlDetailAccessibleNo => 'Not available';

  @override
  String get close => 'Close';

  @override
  String get mlDashTitle => 'AI Panel';

  @override
  String get mlDashModelName => 'XGBoost Regressor';

  @override
  String get mlDashModelDesc =>
      'Machine learning model trained for crowding prediction.';

  @override
  String get mlDashFeatures =>
      'Features: Hour, Weekend, Holiday, Route code, Capacity';

  @override
  String get mlDashPipeline => 'Data Pipeline';

  @override
  String get mlDashStep1 => 'Flutter app sends request';

  @override
  String get mlDashStep2 => 'Node.js API forwards request';

  @override
  String get mlDashStep3 => 'Python FastAPI runs model';

  @override
  String get mlDashStep4 => 'XGBoost generates prediction';

  @override
  String get mlDashBridgeStatus => 'Bridge Status';

  @override
  String get mlDashConnected => 'Connected';

  @override
  String get mlDashDisconnected => 'Disconnected';

  @override
  String get mlDashModelLoaded => 'Model Loaded';

  @override
  String get mlDashModelNotLoaded => 'Model Not Loaded';

  @override
  String get mlDashCheckNow => 'Check status';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageDesc => 'Change app interface language';

  @override
  String get settingsTurkish => 'Türkçe';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsApiEndpoint => 'API Endpoint';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutDesc =>
      'Rota — Istanbul public transit AI crowding prediction app. tech.istanbul Datathon 2026 project.';

  @override
  String get settingsVersion => 'Version';

  @override
  String get mlStatusActive => 'AI Active';

  @override
  String get mlStatusInactive => 'AI Inactive';

  @override
  String get navMap => 'Map';

  @override
  String get mapNearestStop => 'Nearest Stop';

  @override
  String get mapLocationServiceOff =>
      'Location service is disabled. Please enable it in settings.';

  @override
  String get mapLocationDenied => 'Location permission denied.';

  @override
  String get mapLocationDeniedForever =>
      'Location permission permanently denied. Please enable it in settings.';
}
