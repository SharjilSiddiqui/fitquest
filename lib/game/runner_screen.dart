import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/player_data.dart';
import '../intellitoggle/state/intellitoggle_provider.dart';
import '../services/feature_flag_service.dart';
import 'collectible.dart';
import 'game_constants.dart';
import 'game_over_dialog.dart';
import 'game_state.dart';
import 'hud.dart';
import 'obstacle.dart';
import 'pause_menu.dart';
import 'player.dart';
import 'runner_engine.dart';

class AdventureRunScreen extends StatefulWidget {
  const AdventureRunScreen({
    super.key,
    required this.player,
    required this.featureFlags,
    required this.intellitoggle,
    required this.active,
    required this.onPlayerChanged,
    required this.onSave,
  });

  final PlayerData player;
  final FeatureFlagService featureFlags;
  final IntellitoggleProvider intellitoggle;
  final bool active;
  final ValueChanged<PlayerData> onPlayerChanged;
  final Future<void> Function(PlayerData player) onSave;

  @override
  State<AdventureRunScreen> createState() => _AdventureRunScreenState();
}

class _AdventureRunScreenState extends State<AdventureRunScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late RunnerEngine _engine;
  late AnimationController _ticker;
  Duration? _lastElapsed;
  late PlayerData _currentPlayer;
  final FocusNode _focusNode = FocusNode();
  bool _gameOverDialogShown = false;
  bool _finalizedRun = false;
  bool _pausedBecauseInactive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentPlayer = widget.player;
    _engine = _createEngine();
    _engine.updateIntellitoggleFlags(widget.intellitoggle.activeMap());
    widget.intellitoggle.addListener(_handleIntellitoggleChanged);
    _ticker =
        AnimationController(vsync: this, duration: const Duration(days: 1))
          ..addListener(_tick)
          ..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(covariant AdventureRunScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentPlayer = widget.player;
    if (oldWidget.intellitoggle != widget.intellitoggle) {
      oldWidget.intellitoggle.removeListener(_handleIntellitoggleChanged);
      widget.intellitoggle.addListener(_handleIntellitoggleChanged);
    }
    _engine.updateIntellitoggleFlags(widget.intellitoggle.activeMap());
    if (!widget.active) {
      if (!_engine.state.paused) {
        _pausedBecauseInactive = true;
        _engine.pause();
      }
    } else if (!oldWidget.active && _pausedBecauseInactive) {
      _pausedBecauseInactive = false;
      _engine.resume();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _engine.pause();
      _saveSnapshot(finalize: false);
    }
  }

  @override
  void dispose() {
    _saveSnapshot(finalize: false);
    widget.intellitoggle.removeListener(_handleIntellitoggleChanged);
    WidgetsBinding.instance.removeObserver(this);
    _ticker
      ..removeListener(_tick)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  RunnerEngine _createEngine() {
    return RunnerEngine(
      heroClass: _currentPlayer.heroClass,
      doubleXp: widget.featureFlags.enabled('doublexp'),
      extensionFlags: widget.featureFlags.activeFlags(),
      bestCombo: _currentPlayer.bestRunCombo,
    );
  }

  void _handleIntellitoggleChanged() {
    _engine.updateIntellitoggleFlags(widget.intellitoggle.activeMap());
    if (mounted) setState(() {});
  }

  void _tick() {
    final elapsed = _ticker.lastElapsedDuration ?? Duration.zero;
    final lastElapsed = _lastElapsed;
    _lastElapsed = elapsed;
    if (lastElapsed == null) return;

    final delta =
        (elapsed - lastElapsed).inMicroseconds / Duration.microsecondsPerSecond;
    if (delta <= 0 || delta > 0.08) return;

    _engine.tick(delta);
    _processEvents();
  }

  void _processEvents() {
    for (final event in _engine.takeEvents()) {
      switch (event.type) {
        case RunnerEventType.collectible:
          _applyCollectible(event);
        case RunnerEventType.obstacle:
          break;
        case RunnerEventType.autoSave:
          _saveSnapshot(finalize: false);
        case RunnerEventType.gameOver:
          _saveSnapshot(finalize: true);
          _showGameOverDialog();
      }
    }
  }

  void _applyCollectible(RunnerEvent event) {
    final collectible = event.collectible;
    if (collectible == null) return;

    var next = _currentPlayer.copyWith(
      xp: _currentPlayer.xp + event.xp,
      gold: _currentPlayer.gold + event.gold,
    );

    if (collectible.type == CollectibleType.water) {
      final nextQuestProgress = next.waterQuestProgress < 5
          ? next.waterQuestProgress + 1
          : next.waterQuestProgress;
      final questXp = nextQuestProgress == 5 && next.waterQuestProgress < 5
          ? 50
          : 0;
      next = next.copyWith(
        waterCount: next.waterCount + 1,
        vitality: next.vitality + 1,
        waterQuestProgress: nextQuestProgress,
        xp: next.xp + questXp,
      );
    }

    final item = event.item;
    if (item != null) {
      next = next.copyWith(inventory: [...next.inventory, item]);
    }

    _emitPlayer(next);
  }

  void _emitPlayer(PlayerData next) {
    _currentPlayer = next;
    widget.onPlayerChanged(next);
    if (mounted) setState(() {});
  }

  Future<void> _saveSnapshot({required bool finalize}) async {
    final snapshot = _snapshotPlayer(finalize: finalize);
    _currentPlayer = snapshot;
    widget.onPlayerChanged(snapshot);
    await widget.onSave(snapshot);
  }

  PlayerData _snapshotPlayer({required bool finalize}) {
    final state = _engine.state;
    final distance = state.distance.floor();
    final bestDistance = distance > _currentPlayer.bestRunDistance
        ? distance
        : _currentPlayer.bestRunDistance;
    final totalRunDistance = finalize && !_finalizedRun
        ? _currentPlayer.totalRunDistance + distance
        : _currentPlayer.totalRunDistance;

    if (finalize) {
      _finalizedRun = true;
    }

    return _currentPlayer.copyWith(
      lastRunDistance: distance,
      lastRunXp: state.xpEarned,
      lastRunGold: state.goldEarned,
      lastRunItems: state.itemsCollected,
      lastRunCombo: state.bestCombo,
      bestRunDistance: bestDistance,
      bestRunXp: state.xpEarned > _currentPlayer.bestRunXp
          ? state.xpEarned
          : _currentPlayer.bestRunXp,
      bestRunGold: state.goldEarned > _currentPlayer.bestRunGold
          ? state.goldEarned
          : _currentPlayer.bestRunGold,
      bestRunItems: state.itemsCollected > _currentPlayer.bestRunItems
          ? state.itemsCollected
          : _currentPlayer.bestRunItems,
      bestRunCombo: state.bestCombo > _currentPlayer.bestRunCombo
          ? state.bestCombo
          : _currentPlayer.bestRunCombo,
      totalRunDistance: totalRunDistance,
    );
  }

  void _showGameOverDialog() {
    if (_gameOverDialogShown || !mounted) return;
    _gameOverDialogShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            GameOverDialog(state: _engine.state, onRestart: _restart),
      );
    });
  }

  void _restart() {
    _engine = _createEngine();
    _lastElapsed = _ticker.lastElapsedDuration;
    _gameOverDialogShown = false;
    _finalizedRun = false;
    _focusNode.requestFocus();
    setState(() {});
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.space) {
      _engine.jump();
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _engine.slide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _engine.jump,
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) > 120) {
            _engine.slide();
          }
        },
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _AdventureHeader(
                player: _currentPlayer,
                flags: widget.featureFlags.activeFlags(),
              ),
              const SizedBox(height: 12),
              Card(
                clipBehavior: Clip.antiAlias,
                elevation: 3,
                child: SizedBox(
                  width: double.infinity,
                  height: GameConstants.worldHeight,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final viewportWidth = constraints.maxWidth;
                      _engine.setViewportWidth(viewportWidth);

                      return AnimatedBuilder(
                        animation: _engine,
                        builder: (context, _) {
                          return Stack(
                            children: [
                              _RunnerWorld(
                                state: _engine.state,
                                viewportWidth: viewportWidth,
                                nightMode: widget.intellitoggle.enabled(
                                  'night-mode',
                                ),
                              ),
                              Positioned.fill(
                                child: AdventureHud(
                                  state: _engine.state,
                                  player: _currentPlayer,
                                  onPause: _engine.togglePause,
                                  showDebug: widget.intellitoggle.enabled(
                                    'debug-hud',
                                  ),
                                  activeFlags: widget.intellitoggle.activeMap(),
                                ),
                              ),
                              if (_engine.state.paused)
                                Positioned.fill(
                                  child: PauseMenu(onResume: _engine.resume),
                                ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _RunnerTips(player: _currentPlayer),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdventureHeader extends StatelessWidget {
  const _AdventureHeader({required this.player, required this.flags});

  final PlayerData player;
  final List<String> flags;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                _heroIcon(player.heroClass),
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adventure Run',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${player.heroClass} runner - best ${player.bestRunDistance}m',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (flags.contains('doublexp'))
              const Chip(
                avatar: Icon(Icons.bolt, size: 18),
                label: Text('doublexp'),
              ),
          ],
        ),
      ),
    );
  }
}

class _RunnerWorld extends StatelessWidget {
  const _RunnerWorld({
    required this.state,
    required this.viewportWidth,
    required this.nightMode,
  });

  final AdventureGameState state;
  final double viewportWidth;
  final bool nightMode;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        width: viewportWidth,
        height: GameConstants.worldHeight,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            _Background(
              distance: state.distance,
              viewportWidth: viewportWidth,
              nightMode: nightMode,
            ),
            Positioned(
              left: 0,
              right: 0,
              top: GameConstants.groundY,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
            ),
            for (final collectible in state.collectibles)
              _CollectibleSprite(collectible: collectible),
            for (final obstacle in state.obstacles)
              _ObstacleSprite(obstacle: obstacle),
            _HeroSprite(player: state.player),
          ],
        ),
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background({
    required this.distance,
    required this.viewportWidth,
    required this.nightMode,
  });

  final double distance;
  final double viewportWidth;
  final bool nightMode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final offset = -(distance * 1.8) % 180;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: nightMode
                    ? const [Color(0xFF101826), Color(0xFF263238)]
                    : [
                        colorScheme.tertiaryContainer.withValues(alpha: 0.38),
                        colorScheme.surface,
                      ],
              ),
            ),
          ),
        ),
        if (nightMode) ...[
          const Positioned(
            top: 34,
            right: 72,
            child: Icon(
              Icons.nightlight_round,
              color: Color(0xFFFFF8E1),
              size: 44,
            ),
          ),
          for (var index = 0; index < 14; index++)
            Positioned(
              left: (index * 83 + offset.abs()) % viewportWidth,
              top: 26 + (index % 5) * 22,
              child: const Icon(Icons.star, color: Color(0xFFFFFDE7), size: 10),
            ),
        ],
        for (var index = 0; index < (viewportWidth / 180).ceil() + 2; index++)
          Positioned(
            left: offset + index * 180,
            bottom: 72,
            child: Icon(
              Icons.park,
              size: 72,
              color: nightMode
                  ? const Color(0xFF90A4AE).withValues(alpha: 0.30)
                  : colorScheme.primary.withValues(alpha: 0.22),
            ),
          ),
      ],
    );
  }
}

class _HeroSprite extends StatelessWidget {
  const _HeroSprite({required this.player});

  final RunnerPlayer player;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final height = player.sliding
        ? GameConstants.slideHeight
        : GameConstants.playerHeight;
    final top = player.sliding
        ? GameConstants.groundY - GameConstants.slideHeight
        : player.y;

    return Positioned(
      left: GameConstants.playerX,
      top: top,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        width: GameConstants.playerWidth,
        height: height,
        decoration: BoxDecoration(
          color: player.shielded
              ? colorScheme.tertiaryContainer
              : colorScheme.primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          _heroIcon(player.heroClass),
          color: player.shielded
              ? colorScheme.onTertiaryContainer
              : colorScheme.onPrimary,
        ),
      ),
    );
  }
}

class _CollectibleSprite extends StatelessWidget {
  const _CollectibleSprite({required this.collectible});

  final RunCollectible collectible;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      left: collectible.x,
      top: collectible.y,
      child: Container(
        width: collectible.size,
        height: collectible.size,
        decoration: BoxDecoration(
          color: _collectibleColor(colorScheme),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.12),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(_collectibleIcon(), size: 21),
      ),
    );
  }

  Color _collectibleColor(ColorScheme colorScheme) {
    switch (collectible.type) {
      case CollectibleType.water:
        return colorScheme.tertiaryContainer;
      case CollectibleType.food:
        return colorScheme.secondaryContainer;
      case CollectibleType.xpOrb:
        return colorScheme.primaryContainer;
      case CollectibleType.coin:
        return const Color(0xFFFFE082);
      case CollectibleType.potion:
        return const Color(0xFFE1BEE7);
      case CollectibleType.shield:
        return colorScheme.primaryContainer;
    }
  }

  IconData _collectibleIcon() {
    switch (collectible.type) {
      case CollectibleType.water:
        return Icons.water_drop;
      case CollectibleType.food:
        return Icons.restaurant;
      case CollectibleType.xpOrb:
        return Icons.auto_awesome;
      case CollectibleType.coin:
        return Icons.paid;
      case CollectibleType.potion:
        return Icons.local_drink;
      case CollectibleType.shield:
        return Icons.shield;
    }
  }
}

class _ObstacleSprite extends StatelessWidget {
  const _ObstacleSprite({required this.obstacle});

  final RunObstacle obstacle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bounds = obstacle.bounds;

    return Positioned(
      left: bounds.left,
      top: bounds.top,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: obstacle.hit ? 0.42 : 1,
        child: Container(
          width: bounds.width,
          height: bounds.height,
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _obstacleIcon(),
            color: colorScheme.onErrorContainer,
            size: obstacle.type == ObstacleType.tree ? 34 : 28,
          ),
        ),
      ),
    );
  }

  IconData _obstacleIcon() {
    switch (obstacle.type) {
      case ObstacleType.rock:
        return Icons.landscape;
      case ObstacleType.spike:
        return Icons.warning;
      case ObstacleType.burger:
        return Icons.lunch_dining;
      case ObstacleType.sleepMonster:
        return Icons.bedtime;
      case ObstacleType.tree:
        return Icons.park;
    }
  }
}

class _RunnerTips extends StatelessWidget {
  const _RunnerTips({required this.player});

  final PlayerData player;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _TipChip(icon: Icons.keyboard, label: 'Space / Tap: Jump'),
            _TipChip(icon: Icons.swipe_down, label: 'Down / Swipe: Slide'),
            _TipChip(
              icon: Icons.shield,
              label: _passiveLabel(player.heroClass),
            ),
            _TipChip(
              icon: Icons.sports_martial_arts,
              label: _bossUnlockLabel(player.bestRunDistance),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipChip extends StatelessWidget {
  const _TipChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

IconData _heroIcon(String heroClass) {
  final normalized = heroClass.toLowerCase();
  if (normalized.contains('mage')) return Icons.auto_fix_high;
  if (normalized.contains('ranger')) return Icons.bolt;
  if (normalized.contains('monk')) return Icons.self_improvement;
  return Icons.shield;
}

String _passiveLabel(String heroClass) {
  final normalized = heroClass.toLowerCase();
  if (normalized.contains('warrior')) return 'Warrior: +25 HP';
  if (normalized.contains('ranger')) return 'Ranger: +10% speed';
  if (normalized.contains('mage')) return 'Mage: +10% XP';
  if (normalized.contains('monk')) return 'Monk: longer shield';
  return 'Hero passive active';
}

String _bossUnlockLabel(int bestDistance) {
  if (bestDistance >= 2000) return 'All bosses prepared';
  if (bestDistance >= 1000) return 'Dragon prep at 2000m';
  if (bestDistance >= 500) return 'Forest prep at 1000m';
  return 'Boss prep unlocks at 500m';
}
