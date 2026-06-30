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

  SpawnBatch tick(double delta, double distance, double viewportWidth) {
    _collectibleTimer -= delta;
    _obstacleTimer -= delta;

    final collectibles = <RunCollectible>[];
    final obstacles = <RunObstacle>[];

    if (_collectibleTimer <= 0) {
      collectibles.add(_spawnCollectible(viewportWidth));
      _collectibleTimer = _collectibleInterval(distance);
    }

    if (_obstacleTimer <= 0) {
      obstacles.add(_spawnObstacle(viewportWidth, distance));
      if (distance >= 500 && _random.nextDouble() < 0.28) {
        obstacles.add(_spawnObstacle(viewportWidth + 150, distance));
      }
      _obstacleTimer = _obstacleInterval(distance);
    }

    return SpawnBatch(collectibles: collectibles, obstacles: obstacles);
  }

  RunCollectible _spawnCollectible(double viewportWidth) {
    final roll = _random.nextDouble();
    final type = roll < 0.28
        ? CollectibleType.water
        : roll < 0.46
        ? CollectibleType.coin
        : roll < 0.64
        ? CollectibleType.xpOrb
        : roll < 0.80
        ? CollectibleType.food
        : roll < 0.92
        ? CollectibleType.shield
        : CollectibleType.potion;

    final y = _lerp(150, GameConstants.groundY - 74, _random.nextDouble());
    return RunCollectible(
      id: _nextId++,
      type: type,
      x: viewportWidth + 80 + _random.nextDouble() * 80,
      y: y,
    );
  }

  RunObstacle _spawnObstacle(double viewportWidth, double distance) {
    final roll = _random.nextDouble();
    final type = _obstacleTypeFor(distance, roll);

    return RunObstacle(
      id: _nextId++,
      type: type,
      x: viewportWidth + 80 + _random.nextDouble() * 130,
    );
  }

  ObstacleType _obstacleTypeFor(double distance, double roll) {
    if (distance < 200) {
      return roll < 0.52
          ? ObstacleType.burger
          : roll < 0.84
          ? ObstacleType.rock
          : ObstacleType.spike;
    }

    if (distance < 500) {
      return roll < 0.30
          ? ObstacleType.rock
          : roll < 0.52
          ? ObstacleType.burger
          : roll < 0.72
          ? ObstacleType.spike
          : roll < 0.88
          ? ObstacleType.tree
          : ObstacleType.sleepMonster;
    }

    return roll < 0.23
        ? ObstacleType.rock
        : roll < 0.42
        ? ObstacleType.spike
        : roll < 0.58
        ? ObstacleType.burger
        : roll < 0.76
        ? ObstacleType.tree
        : ObstacleType.sleepMonster;
  }

  double _collectibleInterval(double distance) {
    if (distance < 200) return _lerp(0.62, 1.0, _random.nextDouble());
    if (distance < 500) return _lerp(0.72, 1.16, _random.nextDouble());
    return _lerp(0.78, 1.24, _random.nextDouble());
  }

  double _obstacleInterval(double distance) {
    if (distance < 200) return _lerp(1.85, 2.55, _random.nextDouble());
    if (distance < 500) return _lerp(1.35, 2.05, _random.nextDouble());

    final pressure = ((distance - 500) / 2200).clamp(0.0, 0.35);
    return _lerp(1.02 - pressure, 1.62 - pressure, _random.nextDouble());
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}
