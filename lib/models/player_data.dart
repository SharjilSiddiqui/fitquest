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

  final int strength;
  final int agility;
  final int wisdom;
  final int vitality;

  final int streak;
  final String? lastActiveDate;
  final String? lastQuestResetDate;
  final String? lastRewardClaimDate;
  final int loginRewardDay;

  final List<String> inventory;
  final String? equippedWeapon;
  final String? equippedArmor;
  final String? equippedAccessory;

  final String? activeBossName;
  final int activeBossHp;
  final int bossDefeatCount;
  final List<String> defeatedBosses;

  final List<String> achievements;

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

    required this.strength,
    required this.agility,
    required this.wisdom,
    required this.vitality,

    required this.streak,
    this.lastActiveDate,
    this.lastQuestResetDate,
    this.lastRewardClaimDate,
    required this.loginRewardDay,

    required this.inventory,
    this.equippedWeapon,
    this.equippedArmor,
    this.equippedAccessory,

    this.activeBossName,
    required this.activeBossHp,
    required this.bossDefeatCount,
    required this.defeatedBosses,

    required this.achievements,
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

      strength: 1,
      agility: 1,
      wisdom: 1,
      vitality: 1,

      streak: 0,
      lastActiveDate: null,
      lastQuestResetDate: null,
      lastRewardClaimDate: null,
      loginRewardDay: 1,

      inventory: [],
      equippedWeapon: null,
      equippedArmor: null,
      equippedAccessory: null,

      activeBossName: null,
      activeBossHp: 0,
      bossDefeatCount: 0,
      defeatedBosses: [],

      achievements: [],
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

      strength: json['strength'] ?? 1,
      agility: json['agility'] ?? 1,
      wisdom: json['wisdom'] ?? 1,
      vitality: json['vitality'] ?? 1,

      streak: json['streak'] ?? 0,
      lastActiveDate: json['lastActiveDate'],
      lastQuestResetDate: json['lastQuestResetDate'],
      lastRewardClaimDate: json['lastRewardClaimDate'],
      loginRewardDay: json['loginRewardDay'] ?? 1,

      inventory: List<String>.from(json['inventory'] ?? []),
      equippedWeapon: json['equippedWeapon'],
      equippedArmor: json['equippedArmor'],
      equippedAccessory: json['equippedAccessory'],

      activeBossName: json['activeBossName'],
      activeBossHp: json['activeBossHp'] ?? 0,
      bossDefeatCount: json['bossDefeatCount'] ?? 0,
      defeatedBosses: List<String>.from(json['defeatedBosses'] ?? []),

      achievements: List<String>.from(json['achievements'] ?? []),
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

      'strength': strength,
      'agility': agility,
      'wisdom': wisdom,
      'vitality': vitality,

      'streak': streak,
      'lastActiveDate': lastActiveDate,
      'lastQuestResetDate': lastQuestResetDate,
      'lastRewardClaimDate': lastRewardClaimDate,
      'loginRewardDay': loginRewardDay,

      'inventory': inventory,
      'equippedWeapon': equippedWeapon,
      'equippedArmor': equippedArmor,
      'equippedAccessory': equippedAccessory,

      'activeBossName': activeBossName,
      'activeBossHp': activeBossHp,
      'bossDefeatCount': bossDefeatCount,
      'defeatedBosses': defeatedBosses,

      'achievements': achievements,
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

    int? strength,
    int? agility,
    int? wisdom,
    int? vitality,

    int? streak,
    String? lastActiveDate,
    String? lastQuestResetDate,
    String? lastRewardClaimDate,
    int? loginRewardDay,

    List<String>? inventory,
    String? equippedWeapon,
    String? equippedArmor,
    String? equippedAccessory,
    bool clearEquippedWeapon = false,
    bool clearEquippedArmor = false,
    bool clearEquippedAccessory = false,

    String? activeBossName,
    int? activeBossHp,
    bool clearActiveBoss = false,
    int? bossDefeatCount,
    List<String>? defeatedBosses,

    List<String>? achievements,
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

      strength: strength ?? this.strength,
      agility: agility ?? this.agility,
      wisdom: wisdom ?? this.wisdom,
      vitality: vitality ?? this.vitality,

      streak: streak ?? this.streak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      lastQuestResetDate: lastQuestResetDate ?? this.lastQuestResetDate,
      lastRewardClaimDate: lastRewardClaimDate ?? this.lastRewardClaimDate,
      loginRewardDay: loginRewardDay ?? this.loginRewardDay,

      inventory: inventory ?? this.inventory,
      equippedWeapon: clearEquippedWeapon
          ? null
          : equippedWeapon ?? this.equippedWeapon,
      equippedArmor: clearEquippedArmor
          ? null
          : equippedArmor ?? this.equippedArmor,
      equippedAccessory: clearEquippedAccessory
          ? null
          : equippedAccessory ?? this.equippedAccessory,

      activeBossName: clearActiveBoss
          ? null
          : activeBossName ?? this.activeBossName,
      activeBossHp: clearActiveBoss ? 0 : activeBossHp ?? this.activeBossHp,
      bossDefeatCount: bossDefeatCount ?? this.bossDefeatCount,
      defeatedBosses: defeatedBosses ?? this.defeatedBosses,

      achievements: achievements ?? this.achievements,
    );
  }
}
