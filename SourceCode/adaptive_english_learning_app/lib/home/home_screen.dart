import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/user_profile_service.dart';
import '../widgets/translated_text.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onGoToLessons;
  final UserProfileService _userProfileService = UserProfileService();

  HomeScreen({super.key, required this.onGoToLessons});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: TranslatedText('Please sign in to continue learning.'),
        ),
      );
    }

    _userProfileService.ensureUserProfile(user);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: StreamBuilder(
          stream: _userProfileService.watchUserProfile(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data?.data() ?? <String, dynamic>{};

            final displayName =
                (data['displayName'] as String?)?.trim().isNotEmpty == true
                    ? data['displayName'] as String
                    : (user.email?.split('@').first ?? 'Learner');

            final streakDays = (data['streakDays'] as num?)?.toInt() ?? 0;
            final lessons =
                (data['completedLessonsCount'] as num?)?.toInt() ?? 0;
            final totalMinutes =
                (data['totalMinutesSpent'] as num?)?.toInt() ?? 0;

            final achievements =
                data['achievements'] as Map<String, dynamic>? ?? {};

            final hours = totalMinutes / 60.0;
            const dailyTarget = 5;
            final completedToday = lessons.clamp(0, dailyTarget).toInt();

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopHeader(
                    greeting: 'Good Day',
                    name: displayName,
                  ),
                  const SizedBox(height: 16),
                  _DailyGoalCard(
                    done: completedToday,
                    total: dailyTarget,
                    onContinue: onGoToLessons,
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle(title: 'Your Progress'),
                  const SizedBox(height: 10),
                  _ProgressStatsRow(
                    lessons: lessons,
                    hours: hours,
                    days: streakDays,
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle(title: 'Achievements'),
                  const SizedBox(height: 10),
                  _AchievementsRow(
                    achievements: achievements,
                    lessons: lessons,
                    streakDays: streakDays,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  final String greeting;
  final String name;

  const _TopHeader({
    required this.greeting,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    const headingStyle = TextStyle(
      color: Color(0xFF0F172A),
      fontSize: 22,
      height: 1.2,
      fontWeight: FontWeight.w700,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslatedText(greeting, style: headingStyle),
        Row(
          children: [
            Text('$name! ', style: headingStyle),
            const Icon(
              Icons.wb_sunny_rounded,
              size: 20,
              color: Color(0xFFF59E0B),
            ),
          ],
        ),
      ],
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  final int done;
  final int total;
  final VoidCallback onContinue;

  const _DailyGoalCard({
    required this.done,
    required this.total,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 84,
            width: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF2F80ED)),
                ),
                Text(
                  '$done/$total',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TranslatedText(
                  "You're doing great!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                TranslatedText(
                  'Complete ${total - done} more lessons to reach your daily goal.',
                  style: const TextStyle(
                    height: 1.35,
                    fontSize: 13.5,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F80ED),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const TranslatedText('Continue Learning'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressStatsRow extends StatelessWidget {
  final int lessons;
  final double hours;
  final int days;

  const _ProgressStatsRow({
    required this.lessons,
    required this.hours,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.collections_bookmark_rounded,
            value: '$lessons',
            label: 'Lessons',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_rounded,
            value: hours.toStringAsFixed(1),
            label: 'Hours',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department_rounded,
            value: '$days',
            label: 'Days',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF2F80ED)),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          TranslatedText(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsRow extends StatelessWidget {
  final Map<String, dynamic> achievements;
  final int lessons;
  final int streakDays;

  const _AchievementsRow({
    required this.achievements,
    required this.lessons,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final achievementsList = [
      _Achievement(
        icon: Icons.school_rounded,
        label: 'First Lesson',
        color: const Color(0xFF2F80ED),
        // Unlocked when 1+ lesson completed, regardless of Firestore map state
        unlocked: achievements['firstLesson'] == true || lessons >= 1,
      ),
      _Achievement(
        icon: Icons.local_fire_department_rounded,
        label: '7 Day Streak',
        color: const Color(0xFFF97316),
        unlocked: achievements['sevenDayStreak'] == true || streakDays >= 7,
      ),
      _Achievement(
        icon: Icons.star_rounded,
        label: '10 Lessons',
        color: const Color(0xFFFACC15),
        unlocked: achievements['tenLessons'] == true || lessons >= 10,
      ),
      _Achievement(
        icon: Icons.mic_rounded,
        label: 'Speaking Star',
        color: const Color(0xFFF59E0B),
        // Speaking star requires a speaking practice — Firestore is the only source
        unlocked: achievements['speakingStar'] == true,
      ),
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: achievementsList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) =>
            _AchievementPill(achievement: achievementsList[index]),
      ),
    );
  }
}

class _Achievement {
  final IconData icon;
  final String label;
  final Color color;
  final bool unlocked;

  _Achievement({
    required this.icon,
    required this.label,
    required this.color,
    required this.unlocked,
  });
}

class _AchievementPill extends StatelessWidget {
  final _Achievement achievement;

  const _AchievementPill({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final circleColor =
        achievement.unlocked ? achievement.color : const Color(0xFFD1D5DB);

    final iconColor =
        achievement.unlocked ? Colors.white : const Color(0xFF6B7280);

    final textColor =
        achievement.unlocked ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);

    return Column(
      children: [
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Icon(achievement.icon, color: iconColor),
        ),
        const SizedBox(height: 6),
        TranslatedText(
          achievement.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return TranslatedText(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: Color(0xFF0F172A),
      ),
    );
  }
}
