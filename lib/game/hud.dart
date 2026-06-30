import 'package:flutter/material.dart';

import '../models/player_data.dart';
import 'game_state.dart';

class AdventureHud extends StatelessWidget {
  const AdventureHud({
    super.key,
    required this.state,
    required this.player,
    required this.onPause,
  });

  final AdventureGameState state;
  final PlayerData player;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _HudChip(icon: Icons.route, label: '${state.distance.floor()}m'),
          _HudChip(icon: Icons.bolt, label: '+${state.xpEarned} XP'),
          _HudChip(icon: Icons.paid, label: '+${state.goldEarned} Gold'),
          _HudChip(
            icon: Icons.favorite,
            label: '${state.player.hp}/${state.player.maxHp} HP',
          ),
          _HudChip(
            icon: Icons.local_fire_department,
            label: '${player.streak} day streak',
          ),
          _HudChip(icon: Icons.bubble_chart, label: 'Combo ${state.combo}'),
          IconButton.filledTonal(
            onPressed: onPause,
            icon: Icon(state.paused ? Icons.play_arrow : Icons.pause),
            tooltip: state.paused ? 'Resume' : 'Pause',
          ),
        ],
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      avatar: Icon(icon, size: 18, color: colorScheme.primary),
      label: Text(label),
      side: BorderSide.none,
      backgroundColor: colorScheme.surface.withValues(alpha: 0.92),
      visualDensity: VisualDensity.compact,
    );
  }
}
