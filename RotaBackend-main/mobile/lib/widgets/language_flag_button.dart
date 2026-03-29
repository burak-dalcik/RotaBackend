import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

import '../l10n/locale_scope.dart';

/// Sağ üst: Türkçe iken 🇬🇧 (İngilizceye geç), İngilizce iken 🇹🇷 (Türkçeye dön).
class LanguageFlagButton extends StatelessWidget {
  const LanguageFlagButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final code = Localizations.localeOf(context).languageCode;
    final toEnglish = code == 'tr';

    return IconButton(
      tooltip: toEnglish ? l10n.langSwitchToEnTooltip : l10n.langSwitchToTrTooltip,
      onPressed: LocaleScope.of(context).onToggleLanguage,
      icon: Text(
        toEnglish ? '🇬🇧' : '🇹🇷',
        style: const TextStyle(fontSize: 22),
      ),
    );
  }
}
