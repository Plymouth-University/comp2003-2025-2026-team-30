import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/user_profile_service.dart';
import '../widgets/translated_text.dart';

class ProgressScreen extends StatelessWidget {
  ProgressScreen({super.key});

  final UserProfileService _userProfileService = UserProfileService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: TranslatedText('Please sign in to view progress.')),
      );
    }

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
            final lessons =
                (data['completedLessonsCount'] as num?)?.toInt() ?? 0;
            final streak = (data['streakDays'] as num?)?.toInt() ?? 0;
            final currentXp = (data['currentXp'] as num?)?.toInt() ?? 0;
            final currentLevel = (data['currentLevel'] as num?)?.toInt() ?? 1;
            final totalMinutes =
                (data['totalMinutesSpent'] as num?)?.toInt() ?? 0;
            final hours = totalMinutes / 60.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ScreenHeader(),
                  const SizedBox(height: 20),
                  _OverviewSection(
                    lessons: lessons,
                    hours: hours,
                    streak: streak,
                    currentXp: currentXp,
                    currentLevel: currentLevel,
                  ),
                  const SizedBox(height: 24),
                  const _SkillsSection(),
                  const SizedBox(height: 24),
                  _ThisWeekSection(totalMinutes: totalMinutes),
                  const SizedBox(height: 24),
                  _AchievementsSection(lessons: lessons, streak: streak),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslatedText(
          'Your Progress',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 6),
        Divider(color: Color(0xFFE5E7EB), thickness: 1, height: 1),
      ],
    );
  }
}

class _OverviewSection extends StatelessWidget {
  final int lessons;
  final double hours;
  final int streak;
  final int currentXp;
  final int currentLevel;

  const _OverviewSection({
    required this.lessons,
    required this.hours,
    required this.streak,
    required this.currentXp,
    required this.currentLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Overview'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.collections_bookmark_rounded,
                iconColor: const Color(0xFF2F80ED),
                iconBg: const Color(0xFFEFF6FF),
                value: '$lessons',
                label: 'Lessons',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.alarm_rounded,
                iconColor: const Color(0xFFEF4444),
                iconBg: const Color(0xFFFFF1F2),
                value: hours.toStringAsFixed(1),
                label: 'Time',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFF97316),
                iconBg: const Color(0xFFFFEDD5),
                value: '$streak',
                label: 'Streak',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TranslatedText(
                'Level $currentLevel',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              TranslatedText(
                '$currentXp XP',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 8),
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
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  const _SkillsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _SectionTitle(title: 'Skills'),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SkillCard(
                icon: Icons.headphones_rounded,
                iconColor: Color(0xFF2F80ED),
                iconBg: Color(0xFFEFF6FF),
                borderColor: Color(0xFF2F80ED),
                skill: 'Listening',
                level: 'Intermediate',
                percent: 0.65,
                progressColor: Color(0xFF2F80ED),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _SkillCard(
                icon: Icons.mic_none_rounded,
                iconColor: Color(0xFFF97316),
                iconBg: Color(0xFFFFEDD5),
                borderColor: Color(0xFFF97316),
                skill: 'Speaking',
                level: 'Elementary',
                percent: 0.45,
                progressColor: Color(0xFFF97316),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SkillCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color borderColor;
  final String skill;
  final String level;
  final double percent;
  final Color progressColor;

  const _SkillCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.borderColor,
    required this.skill,
    required this.level,
    required this.percent,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: borderColor, width: 3),
          top: const BorderSide(color: Color(0xFFE5E7EB)),
          right: const BorderSide(color: Color(0xFFE5E7EB)),
          bottom: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText(
                      skill,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TranslatedText(
                      level,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(percent * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThisWeekSection extends StatelessWidget {
  final int totalMinutes;

  const _ThisWeekSection({required this.totalMinutes});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _todayIndex = 1;
  static const _maxValue = 40.0;
  static const _chartHeight = 120.0;

  @override
  Widget build(BuildContext context) {
    final minutes = totalMinutes.clamp(0, 280);
    final value = (minutes / 7).toDouble();
    final values = List<double>.filled(7, value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'This Week'),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: _chartHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: ['40', '30', '20', '10', '0']
                      .map(
                        (v) => TranslatedText(
                          v,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: _chartHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(_days.length, (i) {
                          final barH =
                              (values[i] / _maxValue) * (_chartHeight - 8);
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: Container(
                                height: barH,
                                decoration: BoxDecoration(
                                  color: i == _todayIndex
                                      ? const Color(0xFF2F80ED)
                                      : const Color(0xFFD1D5DB),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(_days.length, (i) {
                        return Expanded(
                          child: TranslatedText(
                            _days[i],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Center(
            child: TranslatedText(
              'Minutes practiced per day',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  final int lessons;
  final int streak;

  const _AchievementsSection({required this.lessons, required this.streak});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      _AchievementData(
        icon: Icons.school_rounded,
        label: 'First Lesson',
        color: const Color(0xFF3B82F6),
        unlocked: lessons > 0,
      ),
      _AchievementData(
        icon: Icons.local_fire_department_rounded,
        label: '7 Day Streak',
        color: const Color(0xFFF97316),
        unlocked: streak >= 7,
      ),
      _AchievementData(
        icon: Icons.star_outline_rounded,
        label: '10 Lessons',
        color: const Color(0xFFFACC15),
        unlocked: lessons >= 10,
      ),
      _AchievementData(
        icon: Icons.mic_rounded,
        label: 'Speaking Star',
        color: const Color(0xFFF97316),
        unlocked: lessons >= 3,
      ),
    ];

    final unlockedCount = achievements.where((a) => a.unlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionTitle(title: 'Achievements'),
            Text(
              '$unlockedCount/${achievements.length}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 1.55,
            children: achievements
                .map((achievement) => _AchievementBadge(data: achievement))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _AchievementData {
  final IconData icon;
  final String label;
  final Color color;
  final bool unlocked;

  const _AchievementData({
    required this.icon,
    required this.label,
    required this.color,
    required this.unlocked,
  });
}

class _AchievementBadge extends StatelessWidget {
  final _AchievementData data;

  const _AchievementBadge({required this.data});

  @override
  Widget build(BuildContext context) {
    final bg = data.unlocked ? data.color : const Color(0xFFF3F4F6);
    final iconColor = data.unlocked ? Colors.white : const Color(0xFF9CA3AF);
    final labelColor = data.unlocked
        ? const Color(0xFF0F172A)
        : const Color(0xFF9CA3AF);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(data.icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 6),
        TranslatedText(
          data.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: labelColor,
            height: 1.3,
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
