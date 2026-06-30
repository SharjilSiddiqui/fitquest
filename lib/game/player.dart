import 'dart:ui';

import 'game_constants.dart';

enum RunnerMotion { running, jumping, sliding }

class RunnerPlayer {
  RunnerPlayer({
    required this.heroClass,
    required this.maxHp,
    int? hp,
    this.y = GameConstants.groundY - GameConstants.playerHeight,
    this.velocityY = 0,
    this.motion = RunnerMotion.running,
    this.shieldSeconds = 0,
    this.shieldCharges = 0,
  }) : hp = hp ?? maxHp;

  final String heroClass;
  final int maxHp;
  int hp;
  double y;
  double velocityY;
  RunnerMotion motion;
  double shieldSeconds;
  int shieldCharges;

  bool get grounded =>
      y >= GameConstants.groundY - GameConstants.playerHeight - 0.5;

  bool get sliding => motion == RunnerMotion.sliding;

  bool get shielded => shieldSeconds > 0 || shieldCharges > 0;

  Rect get bounds {
    final height = sliding
        ? GameConstants.slideHeight
        : GameConstants.playerHeight;
    final top = sliding ? GameConstants.groundY - GameConstants.slideHeight : y;

    return Rect.fromLTWH(
      GameConstants.playerX,
      top,
      GameConstants.playerWidth,
      height,
    );
  }

  void jump({required double velocity}) {
    if (!grounded) return;
    velocityY = velocity;
    motion = RunnerMotion.jumping;
  }

  void slide() {
    if (!grounded) return;
    motion = RunnerMotion.sliding;
  }

  void stopSlide() {
    if (motion == RunnerMotion.sliding) {
      motion = RunnerMotion.running;
    }
  }

  void tick(double delta) {
    shieldSeconds = (shieldSeconds - delta).clamp(0, double.infinity);

    if (!grounded || velocityY < 0) {
      velocityY += GameConstants.gravity * delta;
      y += velocityY * delta;
    }

    final floorY = GameConstants.groundY - GameConstants.playerHeight;
    if (y >= floorY) {
      y = floorY;
      velocityY = 0;
      if (motion == RunnerMotion.jumping) {
        motion = RunnerMotion.running;
      }
    }
  }

  bool absorbHit() {
    if (shieldCharges <= 0) return false;
    shieldCharges -= 1;
    shieldSeconds = 0;
    return true;
  }

  void addShield() {
    shieldCharges = 1;
  }

  void heal(int amount) {
    hp = (hp + amount).clamp(0, maxHp);
  }

  void takeDamage(int amount, {required double shieldDuration}) {
    if (shieldSeconds > 0) return;
    hp = (hp - amount).clamp(0, maxHp);
    shieldSeconds = shieldDuration;
  }
}
