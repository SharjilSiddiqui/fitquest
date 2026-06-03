import 'package:flutter/material.dart';

import '../models/daily_quest.dart';
import '../models/player_data.dart';
import '../services/rpg_service.dart';
import '../services/xp_service.dart';

class HomeDashboardTab extends StatelessWidget {
  const HomeDashboardTab({
    super.key,
    required this.player,
    required this.onClaimDailyReward,
  });

  final PlayerData player;
  final VoidCallback onClaimDailyReward;

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
        DailyRewardCard(player: player, onClaimDailyReward: onClaimDailyReward),
        const SectionTitle(title: 'Quick Stats'),
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
            StatCard(
              icon: Icons.inventory_2,
              label: 'Inventory',
              value: '${player.inventory.length}',
            ),
            StatCard(
              icon: Icons.sports_martial_arts,
              label: 'Power',
              value: '${RpgService.playerPower(player)}',
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
  const HeroDashboardTab({
    super.key,
    required this.player,
    required this.onUseItem,
    required this.onEquipItem,
  });

  final PlayerData player;
  final ValueChanged<String> onUseItem;
  final ValueChanged<String> onEquipItem;

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
          children: [
            AttributeCard(
              icon: Icons.sports_martial_arts,
              label: 'Strength',
              value: RpgService.totalStrength(player),
              bonus: RpgService.strengthBonus(player),
            ),
            AttributeCard(
              icon: Icons.speed,
              label: 'Agility',
              value: RpgService.totalAgility(player),
              bonus: RpgService.agilityBonus(player),
            ),
            AttributeCard(
              icon: Icons.psychology,
              label: 'Wisdom',
              value: RpgService.totalWisdom(player),
              bonus: RpgService.wisdomBonus(player),
            ),
            AttributeCard(
              icon: Icons.favorite,
              label: 'Vitality',
              value: RpgService.totalVitality(player),
              bonus: RpgService.vitalityBonus(player),
            ),
          ],
        ),
        const SectionTitle(title: 'Equipment'),
        EquipmentCard(player: player),
        const SectionTitle(title: 'Inventory'),
        InventoryCard(
          inventory: player.inventory,
          onUseItem: onUseItem,
          onEquipItem: onEquipItem,
        ),
      ],
    );
  }
}

class AchievementsDashboardTab extends StatelessWidget {
  const AchievementsDashboardTab({super.key, required this.achievements});

  final List<String> achievements;

  @override
  Widget build(BuildContext context) {
    return DashboardScrollView(
      storageKey: 'achievements-dashboard',
      children: [
        const SectionTitle(title: 'Achievements'),

        if (achievements.isEmpty)
          const RpgCard(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No achievements unlocked yet')),
            ),
          ),

        ...achievements.map((achievement) {
          final parts = achievement.split('|');
          final title = parts.first;
          final description = parts.length > 1 ? parts[1] : '';

          return RpgCard(
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(description),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class ShopDashboardTab extends StatelessWidget {
  const ShopDashboardTab({
    super.key,
    required this.player,
    required this.onPurchaseItem,
  });

  final PlayerData player;
  final ValueChanged<String> onPurchaseItem;

  @override
  Widget build(BuildContext context) {
    return DashboardScrollView(
      storageKey: 'shop-dashboard',
      children: [
        SectionTitle(title: 'Shop - ${player.gold} Gold'),
        ...RpgService.shopItems.map(
          (item) => RpgCard(
            child: Row(
              children: [
                CircleAvatar(child: Icon(iconForItem(item.name))),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text('${item.description} • ${item.cost} Gold'),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: player.gold >= item.cost
                      ? () => onPurchaseItem(item.name)
                      : null,
                  child: const Text('Buy'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BossBattleDashboardTab extends StatelessWidget {
  const BossBattleDashboardTab({
    super.key,
    required this.player,
    required this.onSelectBoss,
    required this.onAttackBoss,
  });

  final PlayerData player;
  final ValueChanged<String> onSelectBoss;
  final VoidCallback onAttackBoss;

  @override
  Widget build(BuildContext context) {
    final activeBossName = player.activeBossName;
    final activeBoss = activeBossName == null
        ? null
        : RpgService.bossByName(activeBossName);

    return DashboardScrollView(
      storageKey: 'battle-dashboard',
      children: [
        RpgCard(
          child: Row(
            children: [
              const CircleAvatar(child: Icon(Icons.sports_martial_arts)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Player Power',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${RpgService.playerPower(player)} damage per attack'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionTitle(title: 'Active Battle'),
        if (activeBoss == null)
          const RpgCard(child: Text('Select a boss to begin.'))
        else
          RpgCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activeBoss.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text('${player.activeBossHp}/${activeBoss.hp} HP'),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: (player.activeBossHp / activeBoss.hp).clamp(
                      0.0,
                      1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onAttackBoss,
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Attack'),
                  ),
                ),
              ],
            ),
          ),
        const SectionTitle(title: 'Bosses'),
        ...RpgService.bosses.map(
          (boss) => RpgCard(
            child: Row(
              children: [
                const CircleAvatar(child: Icon(Icons.shield)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        boss.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${boss.hp} HP • +${boss.rewardXp} XP • +${boss.rewardGold} Gold',
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => onSelectBoss(boss.name),
                  child: Text(
                    player.activeBossName == boss.name ? 'Active' : 'Select',
                  ),
                ),
              ],
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

class DailyRewardCard extends StatelessWidget {
  const DailyRewardCard({
    super.key,
    required this.player,
    required this.onClaimDailyReward,
  });

  final PlayerData player;
  final VoidCallback onClaimDailyReward;

  @override
  Widget build(BuildContext context) {
    final rewardDay = player.loginRewardDay.clamp(1, 7);
    final claimed = RpgService.isRewardClaimedToday(player);

    return RpgCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            child: Icon(
              rewardDay == 7 ? Icons.inventory_2 : Icons.paid,
              color: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Reward: Day $rewardDay',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(RpgService.rewardLabelForDay(rewardDay)),
              ],
            ),
          ),
          FilledButton(
            onPressed: claimed ? null : onClaimDailyReward,
            child: Text(claimed ? 'Claimed' : 'Claim'),
          ),
        ],
      ),
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
  const AttributeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.bonus,
  });

  final IconData icon;
  final String label;
  final int value;
  final int bonus;

  @override
  Widget build(BuildContext context) {
    return RpgCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            '$value',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            bonus > 0 ? '$label (+$bonus)' : label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class EquipmentCard extends StatelessWidget {
  const EquipmentCard({super.key, required this.player});

  final PlayerData player;

  @override
  Widget build(BuildContext context) {
    return StatListCard(
      stats: [
        StatItem(Icons.gavel, 'Weapon', player.equippedWeapon ?? 'None'),
        StatItem(Icons.security, 'Armor', player.equippedArmor ?? 'None'),
        StatItem(
          Icons.diamond,
          'Accessory',
          player.equippedAccessory ?? 'None',
        ),
      ],
    );
  }
}

class InventoryCard extends StatelessWidget {
  const InventoryCard({
    super.key,
    required this.inventory,
    required this.onUseItem,
    required this.onEquipItem,
  });

  final List<String> inventory;
  final ValueChanged<String> onUseItem;
  final ValueChanged<String> onEquipItem;

  @override
  Widget build(BuildContext context) {
    if (inventory.isEmpty) {
      return const RpgCard(child: Text('Inventory is empty.'));
    }

    final itemCounts = <String, int>{};
    for (final item in inventory) {
      itemCounts[item] = (itemCounts[item] ?? 0) + 1;
    }

    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCounts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final itemName = itemCounts.keys.elementAt(index);
          final count = itemCounts[itemName]!;
          final canUse = RpgService.isConsumable(itemName);
          final canEquip = RpgService.isEquippable(itemName);

          return SizedBox(
            width: 190,
            child: RpgCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(child: Icon(iconForItem(itemName))),
                  const SizedBox(height: 14),
                  Text(
                    itemName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Owned: $count'),
                  const Spacer(),
                  if (canUse)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => onUseItem(itemName),
                        child: const Text('Use'),
                      ),
                    )
                  else if (canEquip)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => onEquipItem(itemName),
                        child: const Text('Equip'),
                      ),
                    )
                  else
                    const Text('Stored'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

IconData iconForItem(String itemName) {
  switch (itemName) {
    case RpgService.smallXpPotion:
    case RpgService.largeXpPotion:
      return Icons.science;
    case RpgService.ironSword:
      return Icons.gavel;
    case RpgService.steelArmor:
      return Icons.security;
    case RpgService.magicRing:
      return Icons.diamond;
    case RpgService.epicChest:
      return Icons.inventory_2;
    default:
      return Icons.category;
  }
}
