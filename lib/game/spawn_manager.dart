import 'dart:math';

import 'collectible.dart';
import 'game_constants.dart';
import 'obstacle.dart';

class SpawnBatch {
  const SpawnBatch({required this.collectibles, required this.obstacles});

  final List<RunCollectible> collectibles;
  final List<RunObstacle> obstacles;
}

class SpawnManager {
  SpawnManager({Random? random}) : _random = random ?? Random();

  final Random _random;
  int _nextId = 0;
  double _collectibleTimer = 0.6;
  double _obstacleTimer = 1.2;

  SpawnBatch tick(double delta, double distance) {
    _collectibleTimer -= delta;
    _obstacleTimer -= delta;

    final collectibles = <RunCollectible>[];
    final obstacles = <RunObstacle>[];

    if (_collectibleTimer <= 0) {
      collectibles.add(_spawnCollectible());
      _collectibleTimer = _lerp(0.72, 1.3, _random.nextDouble());
    }

    if (_obstacleTimer <= 0) {
      obstacles.add(_spawnObstacle());
      final pressure = (distance / 2200).clamp(0.0, 0.45);
      _obstacleTimer = _lerp(
        1.15 - pressure,
        1.9 - pressure,
        _random.nextDouble(),
      );
    }

    return SpawnBatch(collectibles: collectibles, obstacles: obstacles);
  }

  RunCollectible _spawnCollectible() {
    final roll = _random.nextDouble();
    final type = roll < 0.28
        ? CollectibleType.water
        : roll < 0.48
        ? CollectibleType.coin
        : roll < 0.68
        ? CollectibleType.xpOrb
        : roll < 0.86
        ? CollectibleType.food
        : CollectibleType.potion;

    final y = _lerp(150, GameConstants.groundY - 74, _random.nextDouble());
    return RunCollectible(
      id: _nextId++,
      type: type,
      x: GameConstants.spawnX + _random.nextDouble() * 80,
      y: y,
    );
  }

  RunObstacle _spawnObstacle() {
    final roll = _random.nextDouble();
    final type = roll < 0.24
        ? ObstacleType.rock
        : roll < 0.45
        ? ObstacleType.spike
        : roll < 0.64
        ? ObstacleType.burger
        : roll < 0.82
        ? ObstacleType.sleepMonster
        : ObstacleType.tree;

    return RunObstacle(
      id: _nextId++,
      type: type,
      x: GameConstants.spawnX + _random.nextDouble() * 130,
    );
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}
