import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6F7FB);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopHeader(
                name: "User",
                streakDays: 7,
                greeting: "Good Day",
              ),
              const SizedBox(height: 16),

              _DailyGoalCard(
                done: 3,
                total: 5,
                onContinue: () {},
              ),
              const SizedBox(height: 18),

              const _SectionTitle(title: "Recommended for You"),
              const SizedBox(height: 10),
              _RecommendedCard(
                title: "Greetings & Introductions",
                subtitle:
                    "Learn how to introduce yourself and greet others\nin English",
                level: "Beginner",
                minutes: 15,
                category: "Speaking",
                onStart: () {},
              ),
              const SizedBox(height: 18),

              const _SectionTitle(title: "Quick Practice"),
              const SizedBox(height: 10),
              _QuickPracticeGrid(
                items: [
                  _PracticeItem(
                    title: "Practice Speaking",
                    icon: Icons.mic_rounded,
                    color: const Color(0xFFF59E0B),
                    onTap: () {},
                  ),
                  _PracticeItem(
                    title: "Vocabulary Builder",
                    icon: Icons.collections_bookmark_rounded,
                    color: const Color(0xFF22C55E),
                    onTap: () {},
                  ),
                  _PracticeItem(
                    title: "Grammar Tips",
                    icon: Icons.lightbulb_rounded,
                    color: const Color(0xFF3B82F6),
                    onTap: () {},
                  ),
                  _PracticeItem(
                    title: "Daily Quiz",
                    icon: Icons.gps_fixed_rounded,
                    color: const Color(0xFF8B5CF6),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 18),

              _SectionTitleWithAction(
                title: "Your Achievements",
                actionText: "View All",
                onTap: () {},
              ),
              const SizedBox(height: 10),
              const _AchievementsRow(),
              const SizedBox(height: 18),

              const _SectionTitle(title: "Your Progress"),
              const SizedBox(height: 10),
              const _ProgressStatsRow(
                lessons: 42,
                hours: 12.5,
                days: 7,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------- TOP HEADER ---------------- */

class _TopHeader extends StatelessWidget {
  final String greeting;
  final String name;
  final int streakDays;

  const _TopHeader({
    required this.greeting,
    required this.name,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 22,
                height: 1.2,
                fontWeight: FontWeight.w700,
              ),
              children: [
                TextSpan(text: "$greeting,\n"),
                TextSpan(text: "$name! "),
                const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: Icon(Icons.wb_sunny_rounded,
                        size: 20, color: Color(0xFFF59E0B)),
                  ),
                ),
              ],
            ),
          ),
        ),
        _StreakPill(days: streakDays),
        const SizedBox(width: 10),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child:
                const Icon(Icons.settings_rounded, color: Color(0xFF111827)),
          ),
        ),
      ],
    );
  }
}

class _StreakPill extends StatelessWidget {
  final int days;
  const _StreakPill({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDD5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department_rounded,
              size: 18, color: Color(0xFFF97316)),
          const SizedBox(width: 6),
          Text(
            "$days days",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF9A3412),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- DAILY GOAL CARD ---------------- */

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
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Daily Goal",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ProgressRing(progress: progress, done: done, total: total),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "You're doing great!",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Complete ${total - done} more\nlessons to reach\nyour daily goal.",
                      style: const TextStyle(
                        height: 1.35,
                        fontSize: 13.5,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 44,
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
                        child: const Text(
                          "Continue\nLearning",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;
  final int done;
  final int total;

  const _ProgressRing({
    required this.progress,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      width: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 92,
            width: 92,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 9,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2F80ED)),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$done/$total",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Text(
                "lessons",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ---------------- RECOMMENDED CARD ---------------- */

class _RecommendedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String category;
  final String level;
  final int minutes;
  final VoidCallback onStart;

  const _RecommendedCard({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.level,
    required this.minutes,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            color: const Color(0xFFFDEAD9),
            child: const Center(
              child: Icon(Icons.mic_rounded, size: 42, color: Color(0xFF111827)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Chip(text: category, bg: const Color(0xFFFFEDD5), fg: const Color(0xFF9A3412)),
                    _Chip(text: level, bg: const Color(0xFFF3F4F6), fg: const Color(0xFF6B7280)),
                    _Chip(text: "⏱ $minutes min", bg: const Color(0xFFF3F4F6), fg: const Color(0xFF6B7280)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 46,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F80ED),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Start Lesson",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
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

class _Chip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _Chip({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

/* ---------------- QUICK PRACTICE GRID ---------------- */

class _PracticeItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _PracticeItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _QuickPracticeGrid extends StatelessWidget {
  final List<_PracticeItem> items;
  const _QuickPracticeGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, i) {
        final item = items[i];
        return InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 8)),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, size: 34, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/* ---------------- ACHIEVEMENTS ---------------- */

class _AchievementsRow extends StatelessWidget {
  const _AchievementsRow();

  @override
  Widget build(BuildContext context) {
    final items = [
      _Achievement(icon: Icons.school_rounded, label: "First\nLesson", color: const Color(0xFF2F80ED)),
      _Achievement(icon: Icons.local_fire_department_rounded, label: "7 Day\nStreak", color: const Color(0xFFF97316)),
      _Achievement(icon: Icons.star_rounded, label: "10 Lessons", color: const Color(0xFFFACC15)),
      _Achievement(icon: Icons.mic_rounded, label: "Speaking\nStar", color: const Color(0xFFF59E0B)),
      _Achievement(icon: Icons.lock_rounded, label: "50\nLessons", color: const Color(0xFFE5E7EB), locked: true),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final a in items) ...[
            _AchievementPill(achievement: a),
            const SizedBox(width: 14),
          ],
        ],
      ),
    );
  }
}

class _Achievement {
  final IconData icon;
  final String label;
  final Color color;
  final bool locked;

  _Achievement({
    required this.icon,
    required this.label,
    required this.color,
    this.locked = false,
  });
}

class _AchievementPill extends StatelessWidget {
  final _Achievement achievement;
  const _AchievementPill({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final bg = achievement.locked ? const Color(0xFFF3F4F6) : achievement.color;

    return Column(
      children: [
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Icon(
            achievement.icon,
            color: achievement.locked ? const Color(0xFF9CA3AF) : Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          achievement.label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

/* ---------------- PROGRESS STATS ---------------- */

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
        Expanded(child: _StatCard(icon: Icons.collections_bookmark_rounded, value: "$lessons", label: "Lessons")),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(icon: Icons.timer_rounded, value: "$hours", label: "Hours")),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(icon: Icons.local_fire_department_rounded, value: "$days", label: "Days")),
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
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 8)),
        ],
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
          Text(
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

/* ---------------- SECTION TITLES ---------------- */

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

class _SectionTitleWithAction extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onTap;

  const _SectionTitleWithAction({
    required this.title,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2F80ED),
            ),
          ),
        ),
      ],
    );
  }
}


// Nedu's code