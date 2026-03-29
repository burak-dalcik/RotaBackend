import 'package:flutter/material.dart';

/// Dil değişimini tüm ağaçtan erişilebilir kılar (bayrak butonu).
class LocaleScope extends InheritedWidget {
  const LocaleScope({
    super.key,
    required super.child,
    required this.locale,
    required this.onToggleLanguage,
  });

  final Locale locale;
  final VoidCallback onToggleLanguage;

  static LocaleScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'LocaleScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(LocaleScope oldWidget) => locale != oldWidget.locale;
}
