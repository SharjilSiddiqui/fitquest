import 'package:flutter/foundation.dart';

import 'collision.dart';
import 'game_constants.dart';
import 'game_state.dart';
import 'player.dart';
import 'spawn_manager.dart';

class RunnerEngine extends ChangeNotifier {
  RunnerEngine({
    required String heroClass,
    required bool doubleXp,
    required this.extensionFlags,
    int bestCombo = 0,
  }) {
    _doubleXp = doubleXp;
    final normalized = heroClass.toLowerCase();
    final maxHp =
        GameConstants.baseHp +
        (normalized.contains('warrior') ? GameConstants.warriorBonusHp : 0);
    _speedMultiplier = normalized.contains('ranger')
        ? GameConstants.rangerSpeedBonus
        : 1;
    _xpMultiplier = normalized.contains('mage')
        ? GameConstants.mageXpMultiplier
        : 1;
    _shieldMultiplier = normalized.contains('monk')
        ? GameConstants.monkShieldMultiplier
        : 1;

    state = AdventureGameState(
      player: RunnerPlayer(heroClass: heroClass, maxHp: maxHp),
      collectibles: const [],
      obstacles: const [],
      bestCombo: bestCombo,
    );
  }

  final List<String> extensionFlags;
  final SpawnManager _spawnManager = SpawnManager();
  late final bool _doubleXp;
  late final double _speedMultiplier;
  late final double _xpMultiplier;
  late final double _shieldMultiplier;
  double _saveTimer = 0;
  double _slideTimer = 0;
  List<RunnerEvent> _pendingEvents = <RunnerEvent>[];

  late AdventureGameState state;

  List<RunnerEvent> takeEvents() {
    final events = _pendingEvents;
    _pendingEvents = <RunnerEvent>[];
    return events;
  }

  void restart({required String heroClass, required bool doubleXp}) {
    final preservedBestCombo = state.bestCombo;
    final next = RunnerEngine(
      heroClass: heroClass,
      doubleXp: doubleXp,
      extensionFlags: extensionFlags,
      bestCombo: preservedBestCombo,
    );
    state = next.state;
    _pendingEvents = <RunnerEvent>[];
    _saveTimer = 0;
    _slideTimer = 0;
    notifyListeners();
  }

  void togglePause() {
    if (state.gameOver) return;
    state = state.copyWith(paused: !state.paused);
    notifyListeners();
  }

  void pause() {
    if (state.paused || state.gameOver) return;
    state = state.copyWith(paused: true);
    notifyListeners();
  }

  void resume() {
    if (!state.paused || state.gameOver) return;
    state = state.copyWith(paused: false);
    notifyListeners();
  }

  void jump() {
    if (state.paused || state.gameOver) return;
    state.player.jump();
    notifyListeners();
  }

  void slide() {
    if (state.paused || state.gameOver) return;
    state.player.slide();
    _slideTimer = 0.55;
    notifyListeners();
  }

  void tick(double delta) {
    if (state.paused || state.gameOver) return;

    final speed =
        (GameConstants.baseSpeed + state.distance * 0.018).clamp(
          GameConstants.baseSpeed,
          GameConstants.maxSpeed,
        ) *
        _speedMultiplier;
    final dx = speed * delta;
    _saveTimer += delta;
    _slideTimer = (_slideTimer - delta).clamp(0, double.infinity);

    final player = state.player;
    if (_slideTimer == 0) {
      player.stopSlide();
    }
    player.tick(delta);

    final batch = _spawnManager.tick(delta, state.distance);
    var collectibles = [
      ...state.collectibles.map((item) => item.move(dx)),
      ...batch.collectibles,
    ].where((item) => item.x > -80 && !item.collected).toList();
    var obstacles = [
      ...state.obstacles.map((item) => item.move(dx)),
      ...batch.obstacles,
    ].where((item) => item.x > -100).toList();

    var xpEarned = state.xpEarned;
    var goldEarned = state.goldEarned;
    var itemsCollected = state.itemsCollected;
    var combo = state.combo;
    var bestCombo = state.bestCombo;

    final collectedIds = <int>{};
    for (final collectible in collectibles) {
      if (!Collision.intersects(player.bounds, collectible.bounds)) continue;

      collectedIds.add(collectible.id);
      final xp = _scaledXp(collectible.xp);
      xpEarned += xp;
      goldEarned += collectible.gold;
      itemsCollected += 1;
      combo += 1;
      bestCombo = combo > bestCombo ? combo : bestCombo;
      _pendingEvents.add(
        RunnerEvent(
          type: RunnerEventType.collectible,
          collectible: collectible,
          xp: xp,
          gold: collectible.gold,
          item: collectible.inventoryItem,
        ),
      );
    }
    collectibles = collectibles
        .where((item) => !collectedIds.contains(item.id))
        .toList();

    final hitIds = <int>{};
    for (final obstacle in obstacles) {
      if (obstacle.hit ||
          !Collision.intersects(player.bounds, obstacle.bounds)) {
        continue;
      }

      player.takeDamage(
        obstacle.damage,
        shieldDuration: GameConstants.shieldSeconds * _shieldMultiplier,
      );
      combo = 0;
      hitIds.add(obstacle.id);
      _pendingEvents.add(
        RunnerEvent(type: RunnerEventType.obstacle, obstacle: obstacle),
      );
    }
    obstacles = obstacles
        .map((item) => hitIds.contains(item.id) ? item.markHit() : item)
        .toList();

    var gameOver = false;
    if (player.hp <= 0) {
      gameOver = true;
      _pendingEvents.add(const RunnerEvent(type: RunnerEventType.gameOver));
    }

    if (_saveTimer >= GameConstants.autoSaveSeconds) {
      _saveTimer = 0;
      _pendingEvents.add(const RunnerEvent(type: RunnerEventType.autoSave));
    }

    state = state.copyWith(
      player: player,
      collectibles: collectibles,
      obstacles: obstacles,
      distance: state.distance + dx / 10,
      xpEarned: xpEarned,
      goldEarned: goldEarned,
      itemsCollected: itemsCollected,
      combo: combo,
      bestCombo: bestCombo,
      gameOver: gameOver,
      timeSeconds: state.timeSeconds + delta,
    );
    notifyListeners();
  }

  int _scaledXp(int baseXp) {
    if (baseXp == 0) return 0;
    final flagMultiplier = _doubleXp ? 2.0 : 1.0;
    return (baseXp * flagMultiplier * _xpMultiplier).round();
  }
}
