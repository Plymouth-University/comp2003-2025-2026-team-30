import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

import '../services/app_language_service.dart';
import '../services/user_profile_service.dart';

class LanguageRegionScreen extends StatefulWidget {
  const LanguageRegionScreen({super.key});

  @override
  State<LanguageRegionScreen> createState() => _LanguageRegionScreenState();
}

class _LanguageRegionScreenState extends State<LanguageRegionScreen> {
  static const List<String> _languageOptions = [
    'English',
    'Spanish',
    'Mandarin',
    'Hindi',
    'Arabic',
    'French',
    'Portuguese',
    'Russian',
    'Japanese',
    'German',
    'Other',
  ];

  static const List<String> _regionOptions = [
    'Africa',
    'Asia',
    'Europe',
    'North America',
    'South America',
    'Australia / Oceania',
    'Middle East',
  ];

  final UserProfileService _userProfileService = UserProfileService();
  final TextEditingController _sampleTextController = TextEditingController();

  bool _isLoaded = false;
  bool _isDetecting = false;
  bool _isSaving = false;
  String? _nativeLanguage;
  String? _region;
  String? _detectedLanguageCode;
  String? _detectedLanguageLabel;
  String? _statusMessage;

  @override
  void dispose() {
    _sampleTextController.dispose();
    super.dispose();
  }

  void _hydrate(Map<String, dynamic> data) {
    if (_isLoaded) {
      return;
    }

    _nativeLanguage = data['nativeLanguage'] as String?;
    _region = data['region'] as String?;
    _isLoaded = true;
  }

  String _labelForLanguageTag(String tag) {
    final normalized = tag.toLowerCase().split('-').first;
    const map = {
      'en': 'English',
      'es': 'Spanish',
      'zh': 'Mandarin',
      'hi': 'Hindi',
      'ar': 'Arabic',
      'fr': 'French',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'ja': 'Japanese',
      'de': 'German',
    };

    if (map.containsKey(normalized)) {
      return map[normalized]!;
    }

    return tag;
  }

  bool get _languageIdSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _detectLanguage() async {
    final sampleText = _sampleTextController.text.trim();
    if (sampleText.isEmpty) {
      setState(() {
        _statusMessage = 'Enter a short sample text first.';
      });
      return;
    }

    if (!_languageIdSupported) {
      setState(() {
        _statusMessage =
            'Language detection is available on Android and iOS only.';
      });
      return;
    }

    setState(() {
      _isDetecting = true;
      _statusMessage = null;
    });

    final identifier = LanguageIdentifier(confidenceThreshold: 0.3);

    try {
      final languageTag = await identifier.identifyLanguage(sampleText);
      final possibleLanguages = await identifier.identifyPossibleLanguages(
        sampleText,
      );
      final bestMatch = possibleLanguages.isNotEmpty
          ? possibleLanguages.first
          : null;

      setState(() {
        _detectedLanguageCode =
            languageTag == identifier.undeterminedLanguageCode
            ? null
            : languageTag;
        _detectedLanguageLabel = _detectedLanguageCode == null
            ? null
            : _labelForLanguageTag(_detectedLanguageCode!);
        if (_detectedLanguageLabel != null) {
          _nativeLanguage = _detectedLanguageLabel;
        }
        _statusMessage = _detectedLanguageLabel == null
            ? 'No language could be identified. Try a longer sample.'
            : 'Detected ${_detectedLanguageLabel!}${bestMatch == null ? '' : ' (${(bestMatch.confidence * 100).toStringAsFixed(0)}% confidence)'}.';
      });
    } catch (error) {
      setState(() {
        _statusMessage = 'Language detection failed: $error';
      });
    } finally {
      await identifier.close();
      if (mounted) {
        setState(() {
          _isDetecting = false;
        });
      }
    }
  }

  Future<void> _save(String uid) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final preferredLocaleCode =
          AppLanguageService.instance.languageCodeForName(_nativeLanguage) ??
          _detectedLanguageCode ??
          'en';

      await _userProfileService.updateLanguageRegionSettings(
        uid: uid,
        nativeLanguage: _nativeLanguage,
        region: _region,
        detectedLanguageCode: _detectedLanguageCode,
        preferredLocaleCode: preferredLocaleCode,
      );

      await AppLanguageService.instance.setLocale(
        AppLanguageService.instance.localeFromCode(preferredLocaleCode),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Language and region updated.')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update language and region: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to update language and region.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Language & Region')),
      body: StreamBuilder(
        stream: _userProfileService.watchUserProfile(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() ?? <String, dynamic>{};
          _hydrate(data);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Use ML to suggest your language, then pick the region that fits you best.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _sampleTextController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Sample text for language detection',
                    hintText: 'Type a few words or a short sentence...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isDetecting ? null : _detectLanguage,
                        child: Text(
                          _isDetecting ? 'Detecting...' : 'Detect language',
                        ),
                      ),
                    ),
                  ],
                ),
                if (_statusMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _statusMessage!,
                    style: TextStyle(
                      color: _detectedLanguageLabel == null
                          ? Colors.orange.shade800
                          : Colors.green.shade700,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _nativeLanguage,
                  decoration: const InputDecoration(
                    labelText: 'Native language',
                    border: OutlineInputBorder(),
                  ),
                  items: _languageOptions
                      .map(
                        (language) => DropdownMenuItem(
                          value: language,
                          child: Text(language),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _nativeLanguage = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _region,
                  decoration: const InputDecoration(
                    labelText: 'Region',
                    border: OutlineInputBorder(),
                  ),
                  items: _regionOptions
                      .map(
                        (region) => DropdownMenuItem(
                          value: region,
                          child: Text(region),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _region = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _save(user.uid),
                    child: Text(
                      _isSaving ? 'Saving...' : 'Save language & region',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
