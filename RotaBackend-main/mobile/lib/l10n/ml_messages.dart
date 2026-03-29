import 'app_localizations.dart';

import '../models/ml_status.dart';

String localizedMlBanner(MlStatus s, AppLocalizations l10n) {
  if (!s.mlEnabled) return l10n.mlBannerDisabled;
  if (s.bridgeOk != true) return l10n.mlBannerBridgeDown;
  // Sadece sunucu açıkça ml_loaded: false gönderdiyse; null = parse/API belirsiz → yanlış uyarı gösterme
  if (s.modelsLoaded == false) return l10n.mlBannerModelsDown;
  return l10n.mlBannerLive;
}

String? localizedMlDetailLine(MlStatus s, AppLocalizations l10n) {
  if (s.bridgeError != null && s.bridgeError!.isNotEmpty) {
    return l10n.mlBridgeDetail(s.bridgeError!);
  }
  if (s.note != null && s.note!.isNotEmpty) return s.note;
  return null;
}
