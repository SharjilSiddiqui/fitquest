class PlayerData {
  final String heroClass;
  final int level;
  final int xp;
  final int gold;

  final int waterCount;
  final int workoutCount;
  final int walkCount;
  final int meditationCount;
  final int waterQuestProgress;
  final int workoutQuestProgress;
  final int walkQuestProgress;
  final int meditateQuestProgress;
  final int streak;
  final String? lastActiveDate;
  final String? lastQuestResetDate;

  const PlayerData({
    required this.heroClass,
    required this.level,
    required this.xp,
    required this.gold,

    required this.waterCount,
    required this.workoutCount,
    required this.walkCount,
    required this.meditationCount,

    required this.waterQuestProgress,
    required this.workoutQuestProgress,
    required this.walkQuestProgress,
    required this.meditateQuestProgress,

    required this.streak,
    this.lastActiveDate,
    this.lastQuestResetDate,
  });

  factory PlayerData.empty() {
    return const PlayerData(
      heroClass: '',
      level: 1,
      xp: 0,
      gold: 0,

      waterCount: 0,
      workoutCount: 0,
      walkCount: 0,
      meditationCount: 0,

      waterQuestProgress: 0,
      workoutQuestProgress: 0,
      walkQuestProgress: 0,
      meditateQuestProgress: 0,

      streak: 0,
      lastActiveDate: null,
      lastQuestResetDate: null,
    );
  }

  factory PlayerData.fromJson(Map<String, dynamic> json) {
    return PlayerData(
      heroClass: json['heroClass'] ?? '',
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      gold: json['gold'] ?? 0,

      waterCount: json['waterCount'] ?? 0,
      workoutCount: json['workoutCount'] ?? 0,
      walkCount: json['walkCount'] ?? 0,
      meditationCount: json['meditationCount'] ?? 0,

      waterQuestProgress: json['waterQuestProgress'] ?? 0,
      workoutQuestProgress: json['workoutQuestProgress'] ?? 0,
      walkQuestProgress: json['walkQuestProgress'] ?? 0,
      meditateQuestProgress: json['meditateQuestProgress'] ?? 0,

      streak: json['streak'] ?? 0,
      lastActiveDate: json['lastActiveDate'],
      lastQuestResetDate: json['lastQuestResetDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heroClass': heroClass,
      'level': level,
      'xp': xp,
      'gold': gold,

      'waterCount': waterCount,
      'workoutCount': workoutCount,
      'walkCount': walkCount,
      'meditationCount': meditationCount,

      'waterQuestProgress': waterQuestProgress,
      'workoutQuestProgress': workoutQuestProgress,
      'walkQuestProgress': walkQuestProgress,
      'meditateQuestProgress': meditateQuestProgress,

      'streak': streak,
      'lastActiveDate': lastActiveDate,
      'lastQuestResetDate': lastQuestResetDate,
    };
  }

  PlayerData copyWith({
    String? heroClass,
    int? level,
    int? xp,
    int? gold,

    int? waterCount,
    int? workoutCount,
    int? walkCount,
    int? meditationCount,

    int? waterQuestProgress,
    int? workoutQuestProgress,
    int? walkQuestProgress,
    int? meditateQuestProgress,

    int? streak,
    String? lastActiveDate,
    String? lastQuestResetDate,
  }) {
    return PlayerData(
      heroClass: heroClass ?? this.heroClass,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      gold: gold ?? this.gold,

      waterCount: waterCount ?? this.waterCount,
      workoutCount: workoutCount ?? this.workoutCount,
      walkCount: walkCount ?? this.walkCount,
      meditationCount: meditationCount ?? this.meditationCount,

      waterQuestProgress: waterQuestProgress ?? this.waterQuestProgress,

      workoutQuestProgress: workoutQuestProgress ?? this.workoutQuestProgress,

      walkQuestProgress: walkQuestProgress ?? this.walkQuestProgress,

      meditateQuestProgress:
          meditateQuestProgress ?? this.meditateQuestProgress,

      streak: streak ?? this.streak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      lastQuestResetDate: lastQuestResetDate ?? this.lastQuestResetDate,
    );
  }
}
