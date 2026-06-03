class LevelService {
  static const int xpPerLevel = 100;

  static int calculateLevel(int xp) {
    return (xp ~/ xpPerLevel) + 1;
  }

  static int currentLevelXp(int xp) {
    return xp % xpPerLevel;
  }

  static double progress(int xp) {
    return currentLevelXp(xp) / xpPerLevel;
  }

  static bool didLevelUp(int oldXp, int newXp) {
    return calculateLevel(newXp) > calculateLevel(oldXp);
  }
}
