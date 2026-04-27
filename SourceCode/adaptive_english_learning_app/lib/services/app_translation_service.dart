import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'ai_tutor_service.dart';

class AppTranslationService {
  static final AppTranslationService instance =
      AppTranslationService._internal();

  AppTranslationService._internal({
    FirebaseFirestore? firestore,
    http.Client? client,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _client = client ?? http.Client();

  AppTranslationService({FirebaseFirestore? firestore, http.Client? client})
    : this._internal(firestore: firestore, client: client);

  final FirebaseFirestore _firestore;
  final http.Client _client;
  AiTutorConfig? _cachedConfig;

  final Map<String, String> _cache = {};

  Future<AiTutorConfig> _loadConfig({bool refresh = false}) async {
    if (!refresh && _cachedConfig != null) {
      return _cachedConfig!;
    }

    final snapshot = await _firestore.collection('appConfig').doc('ai').get();
    _cachedConfig = AiTutorConfig.fromMap(
      snapshot.data() ?? <String, dynamic>{},
    );
    return _cachedConfig!;
  }

  String _cacheKey(String text, Locale targetLocale) {
    return '${targetLocale.languageCode}::$text';
  }

  Future<String> translate(
    String text, {
    required Locale targetLocale,
    String sourceLanguageCode = 'en',
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return text;
    }

    if (targetLocale.languageCode == sourceLanguageCode) {
      return text;
    }

    final cacheKey = _cacheKey(text, targetLocale);
    final cached = _cache[cacheKey];
    if (cached != null) {
      return cached;
    }

    var config = await _loadConfig();
    if (config.translationEndpoint == null ||
        config.translationEndpoint!.isEmpty) {
      config = await _loadConfig(refresh: true);
    }
    final targetLanguageCode = targetLocale.languageCode;

    final backendTranslation = await _translateViaBackend(
      text: text,
      sourceLanguageCode: sourceLanguageCode,
      targetLanguageCode: targetLanguageCode,
      endpoint: config.translationEndpoint,
    );
    if (backendTranslation != null && backendTranslation.trim().isNotEmpty) {
      _cache[cacheKey] = backendTranslation;
      return backendTranslation;
    }

    final fallbackTranslation = await _translateViaMlKit(
      text: text,
      sourceLanguageCode: sourceLanguageCode,
      targetLanguageCode: targetLanguageCode,
    );
    if (fallbackTranslation != null && fallbackTranslation.trim().isNotEmpty) {
      _cache[cacheKey] = fallbackTranslation;
      return fallbackTranslation;
    }

    return text;
  }

  Future<List<String>> translateMany(
    List<String> texts, {
    required Locale targetLocale,
    String sourceLanguageCode = 'en',
  }) async {
    if (texts.isEmpty) {
      return const <String>[];
    }

    if (targetLocale.languageCode == sourceLanguageCode) {
      return texts;
    }

    final translated = <String>[];
    for (final text in texts) {
      translated.add(
        await translate(
          text,
          targetLocale: targetLocale,
          sourceLanguageCode: sourceLanguageCode,
        ),
      );
    }
    return translated;
  }

  Future<String?> _translateViaBackend({
    required String text,
    required String sourceLanguageCode,
    required String targetLanguageCode,
    required String? endpoint,
  }) async {
    if (endpoint == null || endpoint.isEmpty) {
      return null;
    }

    try {
      final response = await _client.post(
        Uri.parse(endpoint),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'sourceLanguageCode': sourceLanguageCode,
          'targetLanguageCode': targetLanguageCode,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final translations =
          (decoded['translations'] as List<dynamic>?)?.cast<String>() ??
          const <String>[];
      return (decoded['translation'] as String?) ??
          (translations.isNotEmpty ? translations.first : text);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _translateViaMlKit({
    required String text,
    required String sourceLanguageCode,
    required String targetLanguageCode,
  }) async {
    if (kIsWeb) {
      return null;
    }

    final sourceLanguage = _translateLanguageForCode(sourceLanguageCode);
    final targetLanguage = _translateLanguageForCode(targetLanguageCode);
    if (sourceLanguage == null || targetLanguage == null) {
      return null;
    }

    final manager = OnDeviceTranslatorModelManager();

    try {
      await manager.downloadModel(
        sourceLanguage.bcpCode,
        isWifiRequired: false,
      );
      await manager.downloadModel(
        targetLanguage.bcpCode,
        isWifiRequired: false,
      );

      final translator = OnDeviceTranslator(
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      try {
        return await translator.translateText(text);
      } finally {
        await translator.close();
      }
    } catch (_) {
      return null;
    }
  }

  TranslateLanguage? _translateLanguageForCode(String code) {
    switch (code.toLowerCase()) {
      case 'en':
        return TranslateLanguage.english;
      case 'es':
        return TranslateLanguage.spanish;
      case 'zh':
        return TranslateLanguage.chinese;
      case 'hi':
        return TranslateLanguage.hindi;
      case 'ar':
        return TranslateLanguage.arabic;
      case 'fr':
        return TranslateLanguage.french;
      case 'pt':
        return TranslateLanguage.portuguese;
      case 'ru':
        return TranslateLanguage.russian;
      case 'ja':
        return TranslateLanguage.japanese;
      case 'de':
        return TranslateLanguage.german;
      default:
        return null;
    }
  }
}
