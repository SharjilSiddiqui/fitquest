import 'package:flutter/material.dart';

import '../models/player_data.dart';
import '../services/xp_service.dart';
import '../state/session.dart';
import '../widgets/fitquest_dashboard.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.session, required this.player});

  final Session session;
  final PlayerData player;

  @override
  Widget build(BuildContext context) {
    final level = XpService.levelFromXp(player.xp);
    final username = session.email?.split('@').first ?? 'Hero';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            RpgCard(
              child: Row(
                children: [
                  HeroAvatar(heroClass: player.heroClass, size: 76),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.heroClass,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text('Level $level • ${player.xp} XP'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            InfoChip(
                              icon: Icons.paid,
                              label: '${player.gold} Gold',
                            ),
                            InfoChip(
                              icon: Icons.local_fire_department,
                              label: '${player.streak} Streak',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionTitle(title: 'Account Information'),
            StatListCard(
              stats: [
                StatItem(Icons.email, 'Email', session.email ?? 'Unknown'),
                StatItem(Icons.badge, 'User ID', session.userId ?? 'Unknown'),
                StatItem(Icons.person, 'Username', username),
                StatItem(Icons.shield, 'Hero Class', player.heroClass),
                StatItem(Icons.auto_awesome, 'Level', '$level'),
                StatItem(Icons.paid, 'Gold', '${player.gold}'),
                StatItem(
                  Icons.local_fire_department,
                  'Current Streak',
                  '${player.streak}',
                ),
                StatItem(
                  Icons.emoji_events,
                  'Achievements',
                  '${player.achievements.length}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SectionTitle(title: 'Settings'),
            const SettingsPlaceholderCard(
              icon: Icons.notifications,
              title: 'Notifications',
            ),
            const SizedBox(height: 12),
            const SettingsPlaceholderCard(icon: Icons.palette, title: 'Theme'),
            const SizedBox(height: 12),
            const SettingsPlaceholderCard(
              icon: Icons.manage_accounts,
              title: 'Account Settings',
            ),
            const SizedBox(height: 12),
            const SettingsPlaceholderCard(
              icon: Icons.support_agent,
              title: 'Support',
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                session.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPlaceholderCard extends StatelessWidget {
  const SettingsPlaceholderCard({
    super.key,
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return RpgCard(
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
