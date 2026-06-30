import 'package:flutter/material.dart';

import 'game_state.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({
    super.key,
    required this.state,
    required this.onRestart,
  });

  final AdventureGameState state;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Run Complete'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ResultRow(label: 'Distance', value: '${state.distance.floor()}m'),
          _ResultRow(label: 'XP', value: '+${state.xpEarned}'),
          _ResultRow(label: 'Gold', value: '+${state.goldEarned}'),
          _ResultRow(label: 'Items', value: '${state.itemsCollected}'),
          _ResultRow(label: 'Best Combo', value: '${state.bestCombo}'),
        ],
      ),
      actions: [
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onRestart();
          },
          icon: const Icon(Icons.replay),
          label: const Text('Run Again'),
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
