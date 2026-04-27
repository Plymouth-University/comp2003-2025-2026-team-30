import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../onboarding_screen.dart';
import '../services/app_language_service.dart';
import '../services/user_profile_service.dart';
import 'main_navigation.dart';
import '../intro_screens/onboarding_screen.dart' as assessment;

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  String? _lastPreferredLocaleCode;

  void _syncLocale(Map<String, dynamic>? data) {
    final preferredLocaleCode = (data?['preferredLocaleCode'] as String?)
        ?.trim();
    if (preferredLocaleCode == null || preferredLocaleCode.isEmpty) {
      return;
    }

    if (_lastPreferredLocaleCode == preferredLocaleCode) {
      return;
    }

    _lastPreferredLocaleCode = preferredLocaleCode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      AppLanguageService.instance.setLocale(
        AppLanguageService.instance.localeFromCode(preferredLocaleCode),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;
        if (user == null) {
          return const OnBoardingScreen();
        }

        return FutureBuilder<void>(
          future: UserProfileService().ensureUserProfile(user),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return FutureBuilder(
              future: UserProfileService().fetchUserProfile(user.uid),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final data = userSnapshot.data?.data();
                _syncLocale(data);
                final onboardingCompleted =
                    data?['onboardingCompleted'] as bool? ?? false;

                if (!onboardingCompleted) {
                  return assessment.OnboardingScreen(uid: user.uid);
                }

                return const MainNavigation();
              },
            );
          },
        );
      },
    );
  }
}
