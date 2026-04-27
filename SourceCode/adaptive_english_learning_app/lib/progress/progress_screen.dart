import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/user_profile_service.dart';
import 'lessons_data.dart';


// Data model


class _ProgressData {
  final int completedLessonsCount;
  final double hours;
  final int streakDays;
  final int currentXp;
  final int currentLevel;
  final Map<String, double> skillPercents;
  final List<double> weeklyMinutes;
  final List<String> weekDayLabels;

  const _ProgressData({
    required this.completedLessonsCount,
    required this.hours,
    required this.streakDays,
    required this.currentXp,
    required this.currentLevel,
    required this.skillPercents,
    required this.weeklyMinutes,
    required this.weekDayLabels,
  });
}




// TODO: refine these thresholds with the team once more lessons are added.
String _levelLabel(double percent) {
  if (percent <= 0.25) return 'Beginner';
  if (percent <= 0.50) return 'Elementary';
  if (percent <= 0.75) return 'Intermediate';
  return 'Advanced';
}

String _dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

// Screen


class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _loading = true;
  String? _error;
  _ProgressData? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = 'not_signed_in';
        _loading = false;
      });
      return;
    }

    try {
      final db = FirebaseFirestore.instance;
      final today = DateTime.now();
      final weekDates =
          List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

      // Kick off all three fetches in parallel before awaiting any.
      final userDocFuture = UserProfileService().fetchUserProfile(user.uid);
      final progressFuture = db
          .collection('users')
          .doc(user.uid)
          .collection('lessonProgress')
          .get();
      final statDocFuture = Future.wait(
        weekDates.map(
          (d) => db
              .collection('users')
              .doc(user.uid)
              .collection('dailyStats')
              .doc(_dateKey(d))
              .get(),
        ),
      );

      final userDoc = await userDocFuture;
      final progressSnap = await progressFuture;
      final statDocs = await statDocFuture;

      // User stats 
      final userData = userDoc.data() ?? <String, dynamic>{};
      final completedLessonsCount =
          (userData['completedLessonsCount'] as num?)?.toInt() ?? 0;
      final totalMinutes =
          (userData['totalMinutesSpent'] as num?)?.toInt() ?? 0;
      final streakDays = (userData['streakDays'] as num?)?.toInt() ?? 0;
      final currentXp = (userData['currentXp'] as num?)?.toInt() ?? 0;
      final currentLevel = (userData['currentLevel'] as num?)?.toInt() ?? 1;

      // Skill percents 
      // Totals come from the static catalogue so the denominator updates
      // automatically when new lessons are added to lessons_data.dart.
      final totalBySkill = <String, int>{};
      for (final lesson in kAllLessons) {
        final skill = lesson['skill'] as String;
        totalBySkill[skill] = (totalBySkill[skill] ?? 0) + 1;
      }

      final completedBySkill = <String, int>{};
      for (final doc in progressSnap.docs) {
        final d = doc.data();
        if (d['status'] == 'completed') {
          final skill = d['skill'] as String? ?? '';
          if (skill.isNotEmpty) {
            completedBySkill[skill] = (completedBySkill[skill] ?? 0) + 1;
          }
        }
      }

      final skillPercents = <String, double>{};
      for (final skill in ['Listening', 'Speaking', 'Reading', 'Writing']) {
        final total = totalBySkill[skill] ?? 0;
        final done = completedBySkill[skill] ?? 0;
        skillPercents[skill] =
            total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
      }

      // Weekly chart 
      // activitiesCompleted × 5 min matches the increment used in
      // LearningFirestoreService.recordLessonSectionCompletion.
      final weeklyMinutes = statDocs.map((doc) {
        final acts = (doc.data()?['activitiesCompleted'] as num?)?.toInt() ?? 0;
        return acts * 5.0;
      }).toList();

      final weekDayLabels = weekDates
          .map((d) =>
              ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1])
          .toList();

      setState(() {
        _data = _ProgressData(
          completedLessonsCount: completedLessonsCount,
          hours: totalMinutes / 60.0,
          streakDays: streakDays,
          currentXp: currentXp,
          currentLevel: currentLevel,
          skillPercents: skillPercents,
          weeklyMinutes: weeklyMinutes,
          weekDayLabels: weekDayLabels,
        );
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F7FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error == 'not_signed_in') {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F7FB),
        body: Center(child: Text('Please sign in to view your progress.')),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load your progress. Please try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    final d = _data!;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ScreenHeader(),
              const SizedBox(height: 20),
              _OverviewSection(
                lessons: d.completedLessonsCount,
                hours: d.hours,
                streak: d.streakDays,
                currentXp: d.currentXp,
                currentLevel: d.currentLevel,
              ),
              const SizedBox(height: 24),
              _SkillsSection(skillPercents: d.skillPercents),
              const SizedBox(height: 24),
              _ThisWeekSection(
                weeklyMinutes: d.weeklyMinutes,
                dayLabels: d.weekDayLabels,
              ),
              const SizedBox(height: 24),
              _AchievementsSection(
                lessons: d.completedLessonsCount,
                streak: d.streakDays,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets (visual design unchanged)
// ---------------------------------------------------------------------------

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
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
              Text(
                'Level $currentLevel',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
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
          Text(
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
  final Map<String, double> skillPercents;

  const _SkillsSection({required this.skillPercents});

  @override
  Widget build(BuildContext context) {
    final listeningPct = skillPercents['Listening'] ?? 0.0;
    final speakingPct  = skillPercents['Speaking']  ?? 0.0;
    final readingPct   = skillPercents['Reading']   ?? 0.0;
    final writingPct   = skillPercents['Writing']   ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Skills'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SkillCard(
                icon: Icons.headphones_rounded,
                iconColor: const Color(0xFF2F80ED),
                iconBg: const Color(0xFFEFF6FF),
                borderColor: const Color(0xFF2F80ED),
                skill: 'Listening',
                level: _levelLabel(listeningPct),
                percent: listeningPct,
                progressColor: const Color(0xFF2F80ED),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SkillCard(
                icon: Icons.mic_none_rounded,
                iconColor: const Color(0xFFF97316),
                iconBg: const Color(0xFFFFEDD5),
                borderColor: const Color(0xFFF97316),
                skill: 'Speaking',
                level: _levelLabel(speakingPct),
                percent: speakingPct,
                progressColor: const Color(0xFFF97316),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SkillCard(
                icon: Icons.menu_book_rounded,
                iconColor: const Color(0xFF10B981),
                iconBg: const Color(0xFFECFDF5),
                borderColor: const Color(0xFF10B981),
                skill: 'Reading',
                level: _levelLabel(readingPct),
                percent: readingPct,
                progressColor: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SkillCard(
                icon: Icons.edit_rounded,
                iconColor: const Color(0xFF8B5CF6),
                iconBg: const Color(0xFFF5F3FF),
                borderColor: const Color(0xFF8B5CF6),
                skill: 'Writing',
                level: _levelLabel(writingPct),
                percent: writingPct,
                progressColor: const Color(0xFF8B5CF6),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(color: borderColor, width: 3),
            top: const BorderSide(color: Color(0xFFE5E7EB)),
            right: const BorderSide(color: Color(0xFFE5E7EB)),
            bottom: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
                    Text(
                      skill,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
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
      ),
    );
  }
}

class _ThisWeekSection extends StatelessWidget {
  final List<double> weeklyMinutes;
  final List<String> dayLabels;

  const _ThisWeekSection({
    required this.weeklyMinutes,
    required this.dayLabels,
  });

  static const _maxValue = 40.0;
  static const _chartHeight = 120.0;

  @override
  Widget build(BuildContext context) {
    // Today is always the rightmost bar — weekDates is generated ending with today.
    final todayIndex = weeklyMinutes.length - 1;

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
                        (v) => Text(
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
                        children: List.generate(weeklyMinutes.length, (i) {
                          final barH =
                              (weeklyMinutes[i].clamp(0, _maxValue) /
                                      _maxValue) *
                                  (_chartHeight - 8);
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              child: Container(
                                height: barH,
                                decoration: BoxDecoration(
                                  color: i == todayIndex
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
                      children: List.generate(dayLabels.length, (i) {
                        return Expanded(
                          child: Text(
                            dayLabels[i],
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
            child: Text(
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
    // TODO: agree unlock conditions with the team before wiring these to real data.
    //       Placeholder logic (lessons > 0, streak >= 7, etc.) is left in place for now.
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
    final labelColor =
        data.unlocked ? const Color(0xFF0F172A) : const Color(0xFF9CA3AF);

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
        Text(
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
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: Color(0xFF0F172A),
      ),
    );
  }
}
