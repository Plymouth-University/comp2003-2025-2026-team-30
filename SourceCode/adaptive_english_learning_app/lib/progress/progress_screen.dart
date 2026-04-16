import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _ScreenHeader(),
              SizedBox(height: 20),
              _OverviewSection(),
              SizedBox(height: 24),
              _SkillsSection(),
              SizedBox(height: 24),
              _ThisWeekSection(),
              SizedBox(height: 24),
              _AchievementsSection(),
            ],
          ),
        ),
      ),
    );
  }
}



class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
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
  const _OverviewSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Overview'),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(
              child: _StatCard(
                icon: Icons.collections_bookmark_rounded,
                iconColor: Color(0xFF2F80ED),
                iconBg: Color(0xFFEFF6FF),
                value: '42',
                label: 'Lessons',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.alarm_rounded,
                iconColor: Color(0xFFEF4444),
                iconBg: Color(0xFFFFF1F2),
                value: '12.5h',
                label: 'Time',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department_rounded,
                iconColor: Color(0xFFF97316),
                iconBg: Color(0xFFFFEDD5),
                value: '7',
                label: 'Streak',
              ),
            ),
          ],
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
  const _SkillsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Skills'),
        const SizedBox(height: 12),
        Row(
          children: const [
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
        const SizedBox(height: 10),
        Row(
          children: const [
            Expanded(
              child: _SkillCard(
                icon: Icons.menu_book_outlined,
                iconColor: Color(0xFF22C55E),
                iconBg: Color(0xFFF0FDF4),
                borderColor: Color(0xFF22C55E),
                skill: 'Reading',
                level: 'Intermediate',
                percent: 0.72,
                progressColor: Color(0xFF22C55E),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _SkillCard(
                icon: Icons.edit_outlined,
                iconColor: Color(0xFF8B5CF6),
                iconBg: Color(0xFFF5F3FF),
                borderColor: Color(0xFF8B5CF6),
                skill: 'Writing',
                level: 'Elementary',
                percent: 0.38,
                progressColor: Color(0xFF8B5CF6),
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
    );
  }
}



class _ThisWeekSection extends StatelessWidget {
  const _ThisWeekSection();

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _values = [22.0, 30.0, 13.0, 18.0, 35.0, 17.0, 10.0];
  static const _todayIndex = 1; // Tuesday
  static const _maxValue = 40.0;
  static const _chartHeight = 120.0;

  @override
  Widget build(BuildContext context) {
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
              // Y-axis labels
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
              // Bar chart + day labels
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: _chartHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(_days.length, (i) {
                          final barH =
                              (_values[i] / _maxValue) * (_chartHeight - 8);
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3),
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
                          child: Text(
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
  const _AchievementsSection();

  static final _achievements = [
    _AchievementData(
      icon: Icons.school_rounded,
      label: 'First\nLesson',
      color: const Color(0xFF3B82F6),
      unlocked: true,
    ),
    _AchievementData(
      icon: Icons.local_fire_department_rounded,
      label: '7 Day\nStreak',
      color: const Color(0xFFF97316),
      unlocked: true,
    ),
    _AchievementData(
      icon: Icons.star_outline_rounded,
      label: '10 Lessons',
      color: const Color(0xFFFACC15),
      unlocked: true,
    ),
    _AchievementData(
      icon: Icons.mic_rounded,
      label: 'Speaking\nStar',
      color: const Color(0xFFF97316),
      unlocked: true,
    ),
    _AchievementData(
      icon: Icons.lock_rounded,
      label: '50 Lessons',
      color: const Color(0xFFD1D5DB),
      unlocked: false,
    ),
    _AchievementData(
      icon: Icons.lock_rounded,
      label: 'Perfect\nWeek',
      color: const Color(0xFFD1D5DB),
      unlocked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _achievements.where((a) => a.unlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionTitle(title: 'Achievements'),
            Text(
              '$unlockedCount/${_achievements.length}',
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
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85,
            children:
                _achievements.map((a) => _AchievementBadge(data: a)).toList(),
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
    final bg =
        data.unlocked ? data.color : const Color(0xFFF3F4F6);
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
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
          ),
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
