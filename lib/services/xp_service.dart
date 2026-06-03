class XpService {
  static const int xpPerLevel = 100;

  static int levelFromXp(int xp) {
    return (xp ~/ xpPerLevel) + 1;
  }

  static int addXp(int currentXp, int amount) {
    return currentXp + amount;
  }

  static int currentLevelXp(int xp) {
    return xp % xpPerLevel;
  }

  static double progressToNextLevel(int xp) {
    return currentLevelXp(xp) / xpPerLevel;
  }
}
