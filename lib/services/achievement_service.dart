class AchievementService {
  static List<String> checkAchievements({
    required int waterCount,
    required int workoutCount,
    required int streak,
    required int level,
    required int gold,
  }) {
    final unlocked = <String>[];

    if (waterCount >= 1) {
      unlocked.add('💧 First Drink');
    }

    if (workoutCount >= 1) {
      unlocked.add('🏋 First Workout');
    }

    if (streak >= 7) {
      unlocked.add('🔥 7 Day Streak');
    }

    if (level >= 5) {
      unlocked.add('⭐ Reach Level 5');
    }

    if (gold >= 100) {
      unlocked.add('💰 Earn 100 Gold');
    }

    return unlocked;
  }
}
