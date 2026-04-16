import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with "Profile" title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Profile',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
            ),

            // User Profile Card
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
                    // User info row
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              'M',
                              style:
                                  Theme.of(context).textTheme.displayMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        // Name and badge
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Maria',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Text(
                                  'Intermediate Learner',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                    Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                    ),
                    const SizedBox(height: 20.0),

                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          emoji: '📚',
                          value: '42',
                          label: 'Lessons',
                        ),
                        _StatItem(
                          emoji: '⏱️',
                          value: '12.5h',
                          label: 'Hours',
                        ),
                        _StatItem(
                          emoji: '🔥',
                          value: '7',
                          label: 'Day Streak',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24.0),

            // Settings Menu Card
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
                      title: 'Edit Profile',
                      onTap: () {},
                    ),
                    Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                      indent: 56,
                    ),
                    _MenuItem(
                      icon: Icons.track_changes,
                      title: 'Learning Goals',
                      onTap: () {},
                    ),
                    Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                      indent: 56,
                    ),
                    _MenuItem(
                      icon: Icons.public,
                      title: 'Language & Region',
                      onTap: () {},
                    ),
                    Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                      indent: 56,
                    ),
                    _MenuItem(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                      indent: 56,
                    ),
                    _MenuItem(
                      icon: Icons.help,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                      indent: 56,
                    ),
                    _MenuItem(
                      icon: Icons.info,
                      title: 'About',
                      onTap: () {},
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24.0),

            // Sign Out Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                        'Sign Out',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
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

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'LearnEnglish v1.0.0',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Made with ❤️ for language learners',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32.0),
          ],
        ),
      ),
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
        Text(
          emoji,
          style: const TextStyle(fontSize: 24.0),
        ),
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
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey,
              ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 16.0,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.grey.shade600,
                size: 24.0,
              ),
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