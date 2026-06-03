class AchievementService {
  static List<String> checkAchievements({
    required int waterCount,
    required int workoutCount,
    required int walkCount,
    required int meditationCount,
    required int streak,
    required int level,
    required int gold,
    required int bossDefeatCount,
    required List<String> defeatedBosses,
  }) {
    final unlocked = <String>[];

    if (workoutCount >= 1) {
      unlocked.add('First Workout|Complete first workout');
    }

    if (waterCount >= 50) {
      unlocked.add('Hydration Hero|Drink 50 waters');
    }

    if (walkCount >= 25) {
      unlocked.add('Walker|Complete 25 walks');
    }

    if (meditationCount >= 25) {
      unlocked.add('Meditation Master|Meditate 25 times');
    }

    if (level >= 5) {
      unlocked.add('Level 5 Hero|Reach level 5');
    }

    if (level >= 10) {
      unlocked.add('Level 10 Hero|Reach level 10');
    }

    if (gold >= 1000) {
      unlocked.add('Gold Collector|Reach 1000 gold');
    }

    if (bossDefeatCount >= 1) {
      unlocked.add('Boss Slayer|Defeat first boss');
    }

    if (defeatedBosses.contains('Dragon Whelp')) {
      unlocked.add('Dragon Hunter|Defeat Dragon Whelp');
    }

    return unlocked;
  }
}
