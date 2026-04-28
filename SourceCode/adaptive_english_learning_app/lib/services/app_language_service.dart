import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_translation_service.dart';

class AppLanguageService {
  AppLanguageService._();

  static final AppLanguageService instance = AppLanguageService._();

  static const String _localeCodeKey = 'preferred_locale_code';
  static const Set<String> _rtlLanguageCodes = {'ar', 'fa', 'he', 'ur'};

  final ValueNotifier<Locale?> localeNotifier = ValueNotifier<Locale?>(null);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCode = prefs.getString(_localeCodeKey);
    if (storedCode != null && storedCode.isNotEmpty) {
      final locale = localeFromCode(storedCode);
      localeNotifier.value = locale;

      // After the first frame, all visible TranslatedText widgets have called
      // registerText(). Run a batch preload so that subsequent screen
      // navigations get synchronous cache hits instead of per-string fetches.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppTranslationService.instance.preloadRegisteredTexts(locale);
      });
    }
  }

  Locale localeFromCode(String code) {
    final normalizedCode = code.trim().toLowerCase();
    final languageCode = normalizedCode.split(RegExp('[-_]')).first;
    return Locale(languageCode);
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      localeNotifier.value = null;
      await prefs.remove(_localeCodeKey);
      return;
    }

    await AppTranslationService.instance.preloadRegisteredTexts(locale);
    localeNotifier.value = locale;
    await prefs.setString(_localeCodeKey, locale.languageCode);
  }

  Future<void> setLocaleFromProfile(Map<String, dynamic> profile) async {
    final locale = localeFromProfile(profile);
    await setLocale(locale);
  }

  Locale localeFromProfile(Map<String, dynamic> profile) {
    final preferredLocaleCode = (profile['preferredLocaleCode'] as String?)
        ?.trim();
    if (preferredLocaleCode != null && preferredLocaleCode.isNotEmpty) {
      return localeFromCode(preferredLocaleCode);
    }

    final nativeLanguage = (profile['nativeLanguage'] as String?)?.trim();
    final languageCode = languageCodeForName(nativeLanguage);
    if (languageCode != null) {
      return Locale(languageCode);
    }

    return const Locale('en');
  }

  String? languageCodeForName(String? languageName) {
    switch (languageName?.toLowerCase()) {
      case 'english':
        return 'en';
      case 'spanish':
        return 'es';
      case 'mandarin':
      case 'chinese':
        return 'zh';
      case 'hindi':
        return 'hi';
      case 'arabic':
        return 'ar';
      case 'french':
        return 'fr';
      case 'portuguese':
        return 'pt';
      case 'russian':
        return 'ru';
      case 'japanese':
        return 'ja';
      case 'german':
        return 'de';
      default:
        return null;
    }
  }

  bool isRtlLocale(Locale? locale) {
    if (locale == null) {
      return false;
    }

    return _rtlLanguageCodes.contains(locale.languageCode.toLowerCase());
  }
}
