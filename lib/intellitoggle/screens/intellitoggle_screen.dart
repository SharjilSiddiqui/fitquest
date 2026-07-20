import 'package:flutter/material.dart';

import '../state/intellitoggle_provider.dart';
import '../widgets/flag_card.dart';

class IntellitoggleScreen extends StatefulWidget {
  const IntellitoggleScreen({super.key, required this.provider});

  final IntellitoggleProvider provider;

  @override
  State<IntellitoggleScreen> createState() => _IntellitoggleScreenState();
}

class _IntellitoggleScreenState extends State<IntellitoggleScreen> {
  bool _didRequestInitialLoad = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didRequestInitialLoad) return;
      _didRequestInitialLoad = true;
      if (widget.provider.flags.isEmpty && !widget.provider.loading) {
        widget.provider.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.provider,
      builder: (context, _) {
        final provider = widget.provider;
        return RefreshIndicator(
          onRefresh: () => provider.load(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _Header(provider: provider),
              const SizedBox(height: 14),
              if (provider.loading && provider.flags.isEmpty)
                const _LoadingCard()
              else if (provider.errorMessage != null && provider.flags.isEmpty)
                _ErrorCard(
                  onRetry: () => provider.load(forceRefreshToken: true),
                )
              else ...[
                FilledButton.icon(
                  onPressed: provider.loading ? null : () => provider.load(),
                  icon: provider.loading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    provider.loading ? 'Refreshing...' : 'Refresh Flags',
                  ),
                ),
                const SizedBox(height: 14),
                for (final flag in provider.flags) ...[
                  IntellitoggleFlagCard(flag: flag),
                  const SizedBox(height: 12),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.provider});

  final IntellitoggleProvider provider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.hub, color: colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Intellitoggle',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      const Text('CLI-evaluated feature flag snapshot'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(
                    provider.connected ? Icons.check_circle : Icons.error,
                    size: 18,
                  ),
                  label: Text(
                    provider.connected
                        ? 'Browser demo snapshot'
                        : 'Disconnected',
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.layers, size: 18),
                  label: Text('Environment ${provider.environment}'),
                ),
                Chip(
                  avatar: const Icon(Icons.folder_copy, size: 18),
                  label: Text('Project ${provider.projectId}'),
                ),
                Chip(
                  avatar: const Icon(Icons.schedule, size: 18),
                  label: Text(
                    provider.lastRefresh == null
                        ? 'Not refreshed'
                        : 'Last refresh ${_formatTime(provider.lastRefresh!)}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('Loading Feature Flags...')),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.cloud_off, size: 42),
            const SizedBox(height: 10),
            Text(
              'Unable to connect to Intellitoggle.',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
