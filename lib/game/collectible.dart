import 'dart:ui';

enum CollectibleType { water, food, xpOrb, coin, potion, shield }

class RunCollectible {
  const RunCollectible({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.collected = false,
  });

  final int id;
  final CollectibleType type;
  final double x;
  final double y;
  final bool collected;

  double get size => type == CollectibleType.xpOrb ? 34 : 38;

  int get xp {
    switch (type) {
      case CollectibleType.water:
        return 10;
      case CollectibleType.xpOrb:
        return 25;
      case CollectibleType.food:
      case CollectibleType.coin:
      case CollectibleType.potion:
      case CollectibleType.shield:
        return 0;
    }
  }

  int get gold {
    switch (type) {
      case CollectibleType.food:
        return 5;
      case CollectibleType.coin:
        return 10;
      case CollectibleType.water:
      case CollectibleType.xpOrb:
      case CollectibleType.potion:
      case CollectibleType.shield:
        return 0;
    }
  }

  String? get inventoryItem =>
      type == CollectibleType.potion ? 'Small XP Potion' : null;

  Rect get bounds => Rect.fromLTWH(x, y, size, size);

  RunCollectible move(double dx) =>
      RunCollectible(id: id, type: type, x: x - dx, y: y, collected: collected);

  RunCollectible collect() =>
      RunCollectible(id: id, type: type, x: x, y: y, collected: true);
}
