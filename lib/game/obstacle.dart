import 'dart:ui';

enum ObstacleType { rock, spike, burger, sleepMonster, tree }

class RunObstacle {
  const RunObstacle({
    required this.id,
    required this.type,
    required this.x,
    this.hit = false,
  });

  final int id;
  final ObstacleType type;
  final double x;
  final bool hit;

  double get width {
    switch (type) {
      case ObstacleType.tree:
        return 54;
      case ObstacleType.sleepMonster:
        return 64;
      case ObstacleType.spike:
        return 46;
      case ObstacleType.rock:
      case ObstacleType.burger:
        return 50;
    }
  }

  double get height {
    switch (type) {
      case ObstacleType.tree:
        return 96;
      case ObstacleType.sleepMonster:
        return 58;
      case ObstacleType.spike:
        return 42;
      case ObstacleType.rock:
      case ObstacleType.burger:
        return 48;
    }
  }

  int get damage {
    switch (type) {
      case ObstacleType.burger:
        return 10;
      case ObstacleType.sleepMonster:
        return 30;
      case ObstacleType.tree:
        return 22;
      case ObstacleType.rock:
      case ObstacleType.spike:
        return 18;
    }
  }

  Rect get bounds => Rect.fromLTWH(x, 328 - height, width, height);

  RunObstacle move(double dx) =>
      RunObstacle(id: id, type: type, x: x - dx, hit: hit);

  RunObstacle markHit() => RunObstacle(id: id, type: type, x: x, hit: true);
}
