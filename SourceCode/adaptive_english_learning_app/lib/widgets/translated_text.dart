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
  final AppTranslationService _translationService = AppTranslationService();
  Locale? _locale;
  String? _translated;

  @override
  void initState() {
    super.initState();
    _locale = AppLanguageService.instance.localeNotifier.value;
    AppLanguageService.instance.localeNotifier.addListener(
      _handleLocaleChanged,
    );
    _resolveTranslation();
  }

  @override
  void didUpdateWidget(covariant TranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
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

    setState(() {
      _locale = nextLocale;
      _translated = null;
    });
    _resolveTranslation();
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
