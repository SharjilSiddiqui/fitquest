import 'collectible.dart';
import 'obstacle.dart';
import 'player.dart';

class AdventureGameState {
  const AdventureGameState({
    required this.player,
    required this.collectibles,
    required this.obstacles,
    this.distance = 0,
    this.xpEarned = 0,
    this.goldEarned = 0,
    this.itemsCollected = 0,
    this.combo = 0,
    this.bestCombo = 0,
    this.paused = false,
    this.gameOver = false,
    this.timeSeconds = 0,
  });

  final RunnerPlayer player;
  final List<RunCollectible> collectibles;
  final List<RunObstacle> obstacles;
  final double distance;
  final int xpEarned;
  final int goldEarned;
  final int itemsCollected;
  final int combo;
  final int bestCombo;
  final bool paused;
  final bool gameOver;
  final double timeSeconds;

  AdventureGameState copyWith({
    RunnerPlayer? player,
    List<RunCollectible>? collectibles,
    List<RunObstacle>? obstacles,
    double? distance,
    int? xpEarned,
    int? goldEarned,
    int? itemsCollected,
    int? combo,
    int? bestCombo,
    bool? paused,
    bool? gameOver,
    double? timeSeconds,
  }) {
    return AdventureGameState(
      player: player ?? this.player,
      collectibles: collectibles ?? this.collectibles,
      obstacles: obstacles ?? this.obstacles,
      distance: distance ?? this.distance,
      xpEarned: xpEarned ?? this.xpEarned,
      goldEarned: goldEarned ?? this.goldEarned,
      itemsCollected: itemsCollected ?? this.itemsCollected,
      combo: combo ?? this.combo,
      bestCombo: bestCombo ?? this.bestCombo,
      paused: paused ?? this.paused,
      gameOver: gameOver ?? this.gameOver,
      timeSeconds: timeSeconds ?? this.timeSeconds,
    );
  }
}

enum RunnerEventType { collectible, obstacle, gameOver, autoSave }

class RunnerEvent {
  const RunnerEvent({
    required this.type,
    this.collectible,
    this.obstacle,
    this.xp = 0,
    this.gold = 0,
    this.item,
  });

  final RunnerEventType type;
  final RunCollectible? collectible;
  final RunObstacle? obstacle;
  final int xp;
  final int gold;
  final String? item;
}
