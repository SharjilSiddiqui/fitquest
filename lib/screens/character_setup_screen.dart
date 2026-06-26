import 'package:flutter/material.dart';

import '../models/player_data.dart';
import '../services/cloud_save_service.dart';
import '../state/session.dart';

class CharacterSetupScreen extends StatefulWidget {
  const CharacterSetupScreen({
    super.key,
    required this.session,
    required this.onCharacterCreated,
  });

  final Session session;
  final VoidCallback onCharacterCreated;

  @override
  State<CharacterSetupScreen> createState() => _CharacterSetupScreenState();
}

class _CharacterSetupScreenState extends State<CharacterSetupScreen> {
  String _selectedClass = 'warrior';
  bool _saving = false;

  Future<void> _createCharacter(BuildContext context, String heroClass) async {
    setState(() => _saving = true);

    final cloudSave = CloudSaveService(widget.session.dartStream);

    final player = PlayerData(
      heroClass: heroClass,
      level: 1,
      xp: 0,
      gold: 0,

      waterCount: 0,
      workoutCount: 0,
      walkCount: 0,
      meditationCount: 0,

      waterQuestProgress: 0,
      workoutQuestProgress: 0,
      walkQuestProgress: 0,
      meditateQuestProgress: 0,

      strength: 1,
      agility: 1,
      wisdom: 1,
      vitality: 1,

      streak: 1,
      lastActiveDate: DateTime.now().toIso8601String(),
      loginRewardDay: 1,

      inventory: const [],

      activeBossHp: 0,
      bossDefeatCount: 0,
      defeatedBosses: const [],

      achievements: const [],
    );

    try {
      await cloudSave.savePlayer(
        userId: widget.session.userId!,
        tenantId: widget.session.tenantId!,
        player: player,
      );

      if (!context.mounted) return;

      widget.onCharacterCreated();
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (context.mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const classes = [
      _HeroClassOption(
        name: 'warrior',
        title: 'Warrior',
        description: 'Strong melee fighter with high durability.',
        icon: Icons.shield,
      ),
      _HeroClassOption(
        name: 'mage',
        title: 'Mage',
        description: 'Master of elemental magic and ranged attacks.',
        icon: Icons.auto_fix_high,
      ),
      _HeroClassOption(
        name: 'ranger',
        title: 'Ranger',
        description: 'Fast, agile ranged attacker.',
        icon: Icons.bolt,
      ),
      _HeroClassOption(
        name: 'monk',
        title: 'Monk',
        description: 'Balanced support and spiritual fighter.',
        icon: Icons.self_improvement,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Hero')),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 900
                ? 4
                : width >= 620
                ? 2
                : 1;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Your Class',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pick the hero fantasy that will carry your fitness quest.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 22),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: crossAxisCount == 1 ? 1.55 : 0.82,
                        ),
                        itemCount: classes.length,
                        itemBuilder: (context, index) {
                          final option = classes[index];
                          return _HeroClassCard(
                            option: option,
                            selected: option.name == _selectedClass,
                            onTap: _saving
                                ? null
                                : () {
                                    setState(
                                      () => _selectedClass = option.name,
                                    );
                                  },
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _saving
                              ? null
                              : () => _createCharacter(context, _selectedClass),
                          icon: _saving
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.explore),
                          label: Text(
                            _saving
                                ? 'Creating Hero...'
                                : 'Begin as ${_selectedClass.toUpperCase()}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroClassOption {
  const _HeroClassOption({
    required this.name,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String name;
  final String title;
  final String description;
  final IconData icon;
}

class _HeroClassCard extends StatelessWidget {
  const _HeroClassCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _HeroClassOption option;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: selected ? 1.02 : 1,
      child: Card(
        elevation: selected ? 8 : 2,
        shadowColor: colorScheme.shadow.withValues(
          alpha: selected ? 0.22 : 0.1,
        ),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: selected
                  ? colorScheme.primaryContainer
                  : colorScheme.surface,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: selected
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
                      child: Icon(
                        option.icon,
                        color: selected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    AnimatedOpacity(
                      opacity: selected ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        Icons.check_circle,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  option.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  option.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: selected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
