import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/app_language_service.dart';
import '../services/user_profile_service.dart';
import '../widgets/translated_text.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  static const List<String> _languages = [
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

  final UserProfileService _userProfileService = UserProfileService();
  final TextEditingController _displayNameController = TextEditingController();

  bool _isLoaded = false;
  bool _isSaving = false;
  String? _nativeLanguage;

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  void _hydrate(Map<String, dynamic> data, String fallbackName) {
    if (_isLoaded) {
      return;
    }

    _displayNameController.text =
        (data['displayName'] as String?)?.trim().isNotEmpty == true
        ? data['displayName'] as String
        : fallbackName;
    _nativeLanguage = data['nativeLanguage'] as String?;
    _isLoaded = true;
  }

  Future<void> _save(String uid) async {
    final displayName = _displayNameController.text.trim();

    setState(() {
      _isSaving = true;
    });

    try {
      final preferredLocaleCode =
          AppLanguageService.instance.languageCodeForName(_nativeLanguage) ??
          'en';

      await _userProfileService.updateProfileSettings(
        uid: uid,
        displayName: displayName.isEmpty ? null : displayName,
        nativeLanguage: _nativeLanguage,
        preferredLocaleCode: preferredLocaleCode,
      );

      await AppLanguageService.instance.setLocale(
        AppLanguageService.instance.localeFromCode(preferredLocaleCode),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update profile: $error')),
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
          child: TranslatedText('Please sign in to update your profile.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const TranslatedText('Update Profile')),
      body: StreamBuilder(
        stream: _userProfileService.watchUserProfile(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() ?? <String, dynamic>{};
          _hydrate(data, user.email?.split('@').first ?? 'Learner');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TranslatedText('Update the basics.'),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    label: TranslatedText('Display name'),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _nativeLanguage,
                  decoration: const InputDecoration(
                    label: TranslatedText('Native language'),
                    border: OutlineInputBorder(),
                  ),
                  items: _languages
                      .map(
                        (language) => DropdownMenuItem(
                          value: language,
                          child: TranslatedText(language),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _nativeLanguage = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _save(user.uid),
                    child: TranslatedText(
                      _isSaving ? 'Saving...' : 'Save changes',
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
