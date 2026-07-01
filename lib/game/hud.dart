import 'package:flutter/material.dart';

import '../models/player_data.dart';
import 'game_state.dart';

class AdventureHud extends StatelessWidget {
  const AdventureHud({
    super.key,
    required this.state,
    required this.player,
    required this.onPause,
    required this.showDebug,
    required this.activeFlags,
  });

  final AdventureGameState state;
  final PlayerData player;
  final VoidCallback onPause;
  final bool showDebug;
  final Map<String, bool> activeFlags;

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
          _HudChip(
            icon: Icons.speed,
            label: '${state.stamina.floor()} stamina',
          ),
          IconButton.filledTonal(
            onPressed: onPause,
            icon: Icon(state.paused ? Icons.play_arrow : Icons.pause),
            tooltip: state.paused ? 'Resume' : 'Pause',
          ),
          if (showDebug) ...[
            _HudChip(icon: Icons.bug_report, label: '${state.fps.round()} FPS'),
            _HudChip(
              icon: Icons.speed,
              label: '${state.currentSpeed.round()} speed',
            ),
            _HudChip(icon: Icons.score, label: 'Score ${state.score}'),
            _HudChip(icon: Icons.flag, label: _flagSummary()),
          ],
        ],
      ),
    );
  }

  String _flagSummary() {
    final enabled = activeFlags.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .join(', ');
    return enabled.isEmpty ? 'No Intelli flags' : enabled;
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
