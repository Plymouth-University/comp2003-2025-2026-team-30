import 'package:flutter/material.dart';

import '../services/app_language_service.dart';
import '../services/app_translation_service.dart';

class TranslatedText extends StatefulWidget {
  const TranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  final AppTranslationService _translationService =
      AppTranslationService.instance;
  Locale? _locale;
  String? _translated;

  @override
  void initState() {
    super.initState();
    _locale = AppLanguageService.instance.localeNotifier.value;
    AppLanguageService.instance.localeNotifier.addListener(
      _handleLocaleChanged,
    );
    _translationService.registerText(widget.text);

    // Fast path: use cache synchronously so the first build is already
    // translated (e.g. when navigating to a screen after a locale change
    // has already populated the cache).
    final locale = _locale;
    if (locale == null || locale.languageCode == 'en') {
      _translated = widget.text;
    } else {
      _translated = _translationService.translateSync(
        widget.text,
        targetLocale: locale,
      );
      // Cache miss → kick off async fetch; widget shows original text until done.
      if (_translated == null) {
        _resolveTranslation();
      }
    }
  }

  @override
  void didUpdateWidget(covariant TranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _translationService.registerText(widget.text);
    if (oldWidget.text != widget.text) {
      // Try cache first, fall back to async.
      final locale = _locale;
      if (locale != null && locale.languageCode != 'en') {
        final cached = _translationService.translateSync(
          widget.text,
          targetLocale: locale,
        );
        if (cached != null) {
          setState(() => _translated = cached);
          return;
        }
      }
      _resolveTranslation();
    }
  }

  @override
  void dispose() {
    AppLanguageService.instance.localeNotifier.removeListener(
      _handleLocaleChanged,
    );
    super.dispose();
  }

  void _handleLocaleChanged() {
    final nextLocale = AppLanguageService.instance.localeNotifier.value;
    if (_locale?.languageCode == nextLocale?.languageCode) {
      return;
    }

    // Synchronous fast path: setLocale() calls preloadRegisteredTexts() before
    // updating localeNotifier, so the cache is fully populated by the time this
    // handler fires. translateSync() returns the result without any async gap,
    // meaning the UI updates in the SAME frame with zero delay.
    final instant = (nextLocale == null || nextLocale.languageCode == 'en')
        ? widget.text
        : _translationService.translateSync(
            widget.text,
            targetLocale: nextLocale,
          );

    setState(() {
      _locale = nextLocale;
      _translated = instant; // null only for dynamic/uncached strings
    });

    // Fallback for dynamic strings not covered by preload.
    if (instant == null) {
      _resolveTranslation();
    }
  }

  Future<void> _resolveTranslation() async {
    final locale = _locale;
    if (locale == null || locale.languageCode == 'en') {
      if (mounted) {
        setState(() {
          _translated = widget.text;
        });
      }
      return;
    }

    final translated = await _translationService.translate(
      widget.text,
      targetLocale: locale,
    );

    if (mounted) {
      setState(() {
        _translated = translated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _translated ?? widget.text,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
