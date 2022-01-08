import 'package:flutter/material.dart';

class LocaleChanger extends ChangeNotifier {
  Locale? _locale;

  Locale get locale => _locale ?? const Locale('en');

  void changeLocale(Locale newLocale) {
    if (newLocale == const Locale('en')) {
      _locale = const Locale('en');
    } else if (newLocale == const Locale('es')) {
      _locale = const Locale('es');
    } else {
      _locale = const Locale('ar');
    }
    notifyListeners();
  }
}
