import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'l10n/locale_scope.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const RotaApp());
}

class RotaApp extends StatefulWidget {
  const RotaApp({super.key});

  @override
  State<RotaApp> createState() => _RotaAppState();
}

class _RotaAppState extends State<RotaApp> {
  /// Varsayılan arayüz dili: Türkçe
  Locale _locale = const Locale('tr');

  void _toggleLanguage() {
    setState(() {
      _locale =
          _locale.languageCode == 'tr' ? const Locale('en') : const Locale('tr');
    });
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      locale: _locale,
      onToggleLanguage: _toggleLanguage,
      child: MaterialApp(
        title: 'Rota',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        locale: _locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const HomeScreen(),
      ),
    );
  }
}
