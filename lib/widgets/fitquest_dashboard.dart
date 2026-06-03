import 'package:flutter/material.dart';

import '../models/daily_quest.dart';
import '../models/player_data.dart';
import '../services/xp_service.dart';

class HomeDashboardTab extends StatelessWidget {
  const HomeDashboardTab({super.key, required this.player});

  final PlayerData player;

  @override
  Widget build(BuildContext context) {
    final level = XpService.levelFromXp(player.xp);
    final progress = XpService.progressToNextLevel(player.xp);
    final currentXp = XpService.currentLevelXp(player.xp);

    return DashboardScrollView(
      storageKey: 'home-dashboard',
      children: [
        _HeroSummaryCard(
          heroClass: player.heroClass,
          level: level,
          xp: player.xp,
          gold: player.gold,
          streak: player.streak,
          progress: progress,
          currentXp: currentXp,
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            StatCard(icon: Icons.auto_awesome, label: 'Level', value: '$level'),
            StatCard(icon: Icons.bolt, label: 'XP', value: '${player.xp}'),
            StatCard(icon: Icons.paid, label: 'Gold', value: '${player.gold}'),
            StatCard(
              icon: Icons.local_fire_department,
              label: 'Streak',
              value: '${player.streak} days',
            ),
          ],
        ),
      ],
    );
  }
}

class QuestsDashboardTab extends StatelessWidget {
  const QuestsDashboardTab({
    super.key,
    required this.quests,
    required this.onDrinkWater,
    required this.onWorkout,
    required this.onWalk,
    required this.onMeditate,
  });

  final List<DailyQuest> quests;
  final VoidCallback onDrinkWater;
  final VoidCallback onWorkout;
  final VoidCallback onWalk;
  final VoidCallback onMeditate;

  @override
  Widget build(BuildContext context) {
    return DashboardScrollView(
      storageKey: 'quests-dashboard',
      children: [
        const SectionTitle(title: 'Daily Quests'),
        ...quests.map((quest) => QuestCard(quest: quest)),
        const SizedBox(height: 8),
        const SectionTitle(title: 'Actions'),
        ActivityActionCard(
          icon: Icons.water_drop,
          title: 'Drink Water',
          reward: '+10 XP  +5 Gold',
          onPressed: onDrinkWater,
        ),
        ActivityActionCard(
          icon: Icons.fitness_center,
          title: 'Workout',
          reward: '+25 XP  +10 Gold',
          onPressed: onWorkout,
        ),
        ActivityActionCard(
          icon: Icons.directions_walk,
          title: 'Walk',
          reward: '+15 XP  +5 Gold',
          onPressed: onWalk,
        ),
        ActivityActionCard(
          icon: Icons.self_improvement,
          title: 'Meditate',
          reward: '+20 XP  +5 Gold',
          onPressed: onMeditate,
        ),
      ],
    );
  }
}

class HeroDashboardTab extends StatelessWidget {
  const HeroDashboardTab({super.key, required this.player});

  final PlayerData player;

  @override
  Widget build(BuildContext context) {
    final level = XpService.levelFromXp(player.xp);

    return DashboardScrollView(
      storageKey: 'hero-dashboard',
      children: [
        RpgCard(
          child: Row(
            children: [
              HeroAvatar(heroClass: player.heroClass, size: 72),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.heroClass,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Level $level adventurer'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionTitle(title: 'Player Stats'),
        StatListCard(
          stats: [
            StatItem(Icons.shield, 'Hero Class', player.heroClass),
            StatItem(Icons.auto_awesome, 'Level', '$level'),
            StatItem(Icons.bolt, 'XP', '${player.xp}'),
            StatItem(Icons.paid, 'Gold', '${player.gold}'),
            StatItem(Icons.water_drop, 'Water Count', '${player.waterCount}'),
            StatItem(
              Icons.fitness_center,
              'Workout Count',
              '${player.workoutCount}',
            ),
            StatItem(
              Icons.directions_walk,
              'Walk Count',
              '${player.walkCount}',
            ),
            StatItem(
              Icons.self_improvement,
              'Meditation Count',
              '${player.meditationCount}',
            ),
          ],
        ),
        const SectionTitle(title: 'Attributes'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: const [
            AttributeCard(icon: Icons.sports_martial_arts, label: 'Strength'),
            AttributeCard(icon: Icons.speed, label: 'Agility'),
            AttributeCard(icon: Icons.psychology, label: 'Wisdom'),
            AttributeCard(icon: Icons.favorite, label: 'Vitality'),
          ],
        ),
      ],
    );
  }
}

class AchievementsDashboardTab extends StatelessWidget {
  const AchievementsDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScrollView(
      storageKey: 'achievements-dashboard',
      children: [
        const SectionTitle(title: 'Achievements'),
        RpgCard(
          child: SizedBox(
            height: 260,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Achievements coming soon',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DashboardScrollView extends StatelessWidget {
  const DashboardScrollView({
    super.key,
    required this.storageKey,
    required this.children,
  });

  final String storageKey;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView.separated(
        key: PageStorageKey(storageKey),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: children.length,
      ),
    );
  }
}

class _HeroSummaryCard extends StatelessWidget {
  const _HeroSummaryCard({
    required this.heroClass,
    required this.level,
    required this.xp,
    required this.gold,
    required this.streak,
    required this.progress,
    required this.currentXp,
  });

  final String heroClass;
  final int level;
  final int xp;
  final int gold;
  final int streak;
  final double progress;
  final int currentXp;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return RpgCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heroClass,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Level $level'),
                  ],
                ),
              ),
              HeroAvatar(heroClass: heroClass),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(minHeight: 12, value: progress),
          ),
          const SizedBox(height: 8),
          Text('$currentXp/100 XP to next level'),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(icon: Icons.bolt, label: '$xp XP'),
              InfoChip(icon: Icons.paid, label: '$gold Gold'),
              InfoChip(
                icon: Icons.local_fire_department,
                label: '$streak Day Streak',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RpgCard extends StatelessWidget {
  const RpgCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class HeroAvatar extends StatelessWidget {
  const HeroAvatar({super.key, required this.heroClass, this.size = 88});

  final String heroClass;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        _iconForHeroClass(heroClass),
        size: size * 0.48,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  IconData _iconForHeroClass(String heroClass) {
    final normalized = heroClass.toLowerCase();

    if (normalized.contains('mage') || normalized.contains('wizard')) {
      return Icons.auto_fix_high;
    }

    if (normalized.contains('rogue') || normalized.contains('archer')) {
      return Icons.flash_on;
    }

    if (normalized.contains('healer') || normalized.contains('monk')) {
      return Icons.self_improvement;
    }

    return Icons.shield;
  }
}

class InfoChip extends StatelessWidget {
  const InfoChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: colorScheme.secondaryContainer,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RpgCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuestCard extends StatelessWidget {
  const QuestCard({super.key, required this.quest});

  final DailyQuest quest;

  @override
  Widget build(BuildContext context) {
    final progress = (quest.progress / quest.target).clamp(0.0, 1.0);
    final colorScheme = Theme.of(context).colorScheme;

    return RpgCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: quest.completed
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            child: Icon(
              quest.completed ? Icons.check : _questIcon(quest.title),
              color: quest.completed
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        quest.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text('+${quest.rewardXp} XP'),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(minHeight: 8, value: progress),
                ),
                const SizedBox(height: 6),
                Text('${quest.progress}/${quest.target} complete'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _questIcon(String title) {
    switch (title) {
      case 'Drink Water':
        return Icons.water_drop;
      case 'Workout':
        return Icons.fitness_center;
      case 'Walk':
        return Icons.directions_walk;
      case 'Meditate':
        return Icons.self_improvement;
      default:
        return Icons.flag;
    }
  }
}

class ActivityActionCard extends StatelessWidget {
  const ActivityActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.reward,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String reward;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(child: Icon(icon)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(reward),
                  ],
                ),
              ),
              const Icon(Icons.add_circle),
            ],
          ),
        ),
      ),
    );
  }
}

class StatItem {
  const StatItem(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class StatListCard extends StatelessWidget {
  const StatListCard({super.key, required this.stats});

  final List<StatItem> stats;

  @override
  Widget build(BuildContext context) {
    return RpgCard(
      child: Column(
        children: [
          for (var index = 0; index < stats.length; index++) ...[
            _StatRow(item: stats[index]),
            if (index != stats.length - 1) const Divider(height: 20),
          ],
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.item});

  final StatItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(item.icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(item.label)),
        Flexible(
          child: Text(
            item.value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class AttributeCard extends StatelessWidget {
  const AttributeCard({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return RpgCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text('Coming soon', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
