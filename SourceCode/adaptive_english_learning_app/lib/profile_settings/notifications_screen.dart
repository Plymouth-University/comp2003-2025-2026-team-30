import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../services/user_profile_service.dart';
import '../widgets/translated_text.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final UserProfileService _userProfileService = UserProfileService();
  final NotificationService _notificationService = NotificationService.instance;

  bool _isLoaded = false;
  bool _isSaving = false;
  bool _streakRemindersEnabled = false;
  bool _lessonRemindersEnabled = false;

  void _hydrate(Map<String, dynamic> data) {
    if (_isLoaded) {
      return;
    }

    _streakRemindersEnabled = data['streakRemindersEnabled'] as bool? ?? false;
    _lessonRemindersEnabled = data['lessonRemindersEnabled'] as bool? ?? false;
    _isLoaded = true;
  }

  Future<void> _save(String uid) async {
    setState(() {
      _isSaving = true;
    });

    try {
      await _userProfileService.updateNotificationSettings(
        uid: uid,
        streakRemindersEnabled: _streakRemindersEnabled,
        lessonRemindersEnabled: _lessonRemindersEnabled,
      );

      final shouldSchedule = _streakRemindersEnabled || _lessonRemindersEnabled;
      final permissionGranted = shouldSchedule
          ? await _notificationService.ensurePermissions()
          : true;

      if (_streakRemindersEnabled && permissionGranted) {
        await _notificationService.scheduleStreakReminder();
      } else {
        await _notificationService.cancelStreakReminder();
      }

      if (_lessonRemindersEnabled && permissionGranted) {
        await _notificationService.scheduleLessonReminder();
      } else {
        await _notificationService.cancelLessonReminder();
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            permissionGranted
                ? 'Notification preferences updated.'
                : 'Preferences saved, but notification permission is disabled.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update notifications: $error')),
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
          child: TranslatedText('Please sign in to update notifications.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const TranslatedText('Notifications')),
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
                const TranslatedText(
                  'Choose which reminders you want to receive.',
                ),
                const SizedBox(height: 20),
                SwitchListTile.adaptive(
                  value: _streakRemindersEnabled,
                  onChanged: (value) {
                    setState(() {
                      _streakRemindersEnabled = value;
                    });
                  },
                  title: const TranslatedText('Streak reminders'),
                  subtitle: const TranslatedText(
                    'Get a reminder when you have not practiced enough to keep your streak alive.',
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  value: _lessonRemindersEnabled,
                  onChanged: (value) {
                    setState(() {
                      _lessonRemindersEnabled = value;
                    });
                  },
                  title: const TranslatedText('Lesson reminders'),
                  subtitle: const TranslatedText(
                    'Get reminders to continue your learning journey with the next lesson.',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _save(user.uid),
                    child: TranslatedText(
                      _isSaving ? 'Saving...' : 'Save reminders',
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
