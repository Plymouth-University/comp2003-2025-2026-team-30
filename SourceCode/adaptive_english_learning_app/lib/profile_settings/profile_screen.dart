import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth_service.dart';
import '../login_page.dart';
import '../services/app_language_service.dart';
import '../services/app_translation_service.dart';
import '../services/user_profile_service.dart';
import 'language_region_screen.dart';
import 'learning_goals_screen.dart';
import 'update_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static final UserProfileService _userProfileService = UserProfileService();
  static const List<String> _baseLabels = [
    'Please sign in to view your profile.',
    'Profile',
    'Lessons',
    'Hours',
    'Day Streak',
    'Update Profile',
    'Learning Goals + Style',
    'Language & Region',
    'Notifications',
    'Help & Support',
    'About',
    'Sign Out',
    'LearnEnglish v1.0.0',
    'Made with ❤️ for language learners',
  ];

  Future<List<String>>? _translatedLabelsFuture;
  Locale? _lastLocale;

  @override
  void initState() {
    super.initState();
    _refreshTranslations();
    AppLanguageService.instance.localeNotifier.addListener(_handleLocaleChange);
  }

  @override
  void dispose() {
    AppLanguageService.instance.localeNotifier.removeListener(
      _handleLocaleChange,
    );
    super.dispose();
  }

  void _handleLocaleChange() {
    setState(_refreshTranslations);
  }

  void _refreshTranslations() {
    final locale =
        AppLanguageService.instance.localeNotifier.value ?? const Locale('en');
    if (_lastLocale == locale && _translatedLabelsFuture != null) {
      return;
    }

    _lastLocale = locale;
    _translatedLabelsFuture = AppTranslationService.instance.translateMany(
      _baseLabels,
      targetLocale: locale,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<List<String>>(
      future: _translatedLabelsFuture,
      initialData: _baseLabels,
      builder: (context, labelsSnapshot) {
        final labels = labelsSnapshot.data ?? _baseLabels;

        if (user == null) {
          return Scaffold(body: Center(child: Text(labels[0])));
        }

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    labels[1],
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: _userProfileService.watchUserProfile(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snapshot.data?.data() ?? <String, dynamic>{};
                    final displayName =
                        (data['displayName'] as String?)?.trim().isNotEmpty ==
                            true
                        ? data['displayName'] as String
                        : (user.email?.split('@').first ?? 'Learner');
                    final level =
                        data['proficiencyLevel'] as String? ?? 'Learner';
                    final lessons =
                        (data['completedLessonsCount'] as num?)?.toInt() ?? 0;
                    final totalMinutes =
                        (data['totalMinutesSpent'] as num?)?.toInt() ?? 0;
                    final hours = (totalMinutes / 60).toStringAsFixed(1);
                    final streak = (data['streakDays'] as num?)?.toInt() ?? 0;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF3B82F6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          displayName.isNotEmpty
                                              ? displayName.characters.first
                                                    .toUpperCase()
                                              : '?',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0,
                                              vertical: 6.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF52B788),
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            child: Text(
                                              level,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20.0),
                                Divider(color: Colors.grey.shade200, height: 1),
                                const SizedBox(height: 20.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _StatItem(
                                      emoji: '📚',
                                      value: '$lessons',
                                      label: labels[2],
                                    ),
                                    _StatItem(
                                      emoji: '⏱️',
                                      value: hours,
                                      label: labels[3],
                                    ),
                                    _StatItem(
                                      emoji: '🔥',
                                      value: '$streak',
                                      label: labels[4],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                _MenuItem(
                                  icon: Icons.edit,
                                  title: labels[5],
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const UpdateProfileScreen(),
                                      ),
                                    );
                                  },
                                ),
                                Divider(
                                  color: Colors.grey.shade200,
                                  height: 1,
                                  indent: 56,
                                ),
                                _MenuItem(
                                  icon: Icons.track_changes,
                                  title: labels[6],
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const LearningGoalsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                Divider(
                                  color: Colors.grey.shade200,
                                  height: 1,
                                  indent: 56,
                                ),
                                _MenuItem(
                                  icon: Icons.public,
                                  title: labels[7],
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const LanguageRegionScreen(),
                                      ),
                                    );
                                  },
                                ),
                                Divider(
                                  color: Colors.grey.shade200,
                                  height: 1,
                                  indent: 56,
                                ),
                                _MenuItem(
                                  icon: Icons.notifications,
                                  title: labels[8],
                                  onTap: () {},
                                ),
                                Divider(
                                  color: Colors.grey.shade200,
                                  height: 1,
                                  indent: 56,
                                ),
                                _MenuItem(
                                  icon: Icons.help,
                                  title: labels[9],
                                  onTap: () {},
                                ),
                                Divider(
                                  color: Colors.grey.shade200,
                                  height: 1,
                                  indent: 56,
                                ),
                                _MenuItem(
                                  icon: Icons.info,
                                  title: labels[10],
                                  onTap: () {},
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () async {
                                try {
                                  await AuthService().signOut();
                                  if (!context.mounted) return;

                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                    (route) => false,
                                  );
                                } catch (error) {
                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Sign out failed: $error'),
                                    ),
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFEF4444),
                                  width: 2.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '📤',
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    labels[11],
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: const Color(0xFFEF4444),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32.0),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                labels[12],
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(color: Colors.grey),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                labels[13],
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32.0),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _StatItem({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24.0)),
        const SizedBox(height: 8.0),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLast;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade600, size: 24.0),
              const SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (!isLast)
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 24.0,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
