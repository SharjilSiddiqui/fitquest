import 'package:flutter/material.dart';

class PauseMenu extends StatelessWidget {
  const PauseMenu({super.key, required this.onResume});

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.28),
      child: Center(
        child: Card(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pause_circle, size: 48, color: colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  'Adventure Paused',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onResume,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Resume Run'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
