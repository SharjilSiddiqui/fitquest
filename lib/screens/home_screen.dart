import 'package:flutter/material.dart';

import '../state/session.dart';
import '../models/player_data.dart';
import '../services/cloud_save_service.dart';
import '../models/daily_quest.dart';
import '../services/level_service.dart';
import '../services/rpg_service.dart';
import '../widgets/fitquest_dashboard.dart';
import '../services/achievement_service.dart';
import 'inventory_screen.dart';
import 'profile_screen.dart';
import '../services/feature_flag_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.session, required this.player});

  final Session session;
  final PlayerData player;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PlayerData player;
  late List<DailyQuest> quests;
  late FeatureFlagService featureFlags;
  int _selectedTab = 0;

  Future<void> savePlayer() async {
    final cloudSave = CloudSaveService(widget.session.dartStream);

    await cloudSave.savePlayer(
      userId: widget.session.userId!,
      tenantId: widget.session.tenantId!,
      player: player,
    );
  }

  Future<void> _loadFlags() async {
    await featureFlags.load();

    if (mounted) {
      setState(() {});
    }
  }

  void checkDailyStreak() {
    final today = DateTime.now();

    if (player.lastActiveDate == null) {
      player = player.copyWith(
        streak: 1,
        lastActiveDate: today.toIso8601String(),
      );

      savePlayer();
      return;
    }

    final lastDate = DateTime.parse(player.lastActiveDate!);

    final difference = today.difference(lastDate).inDays;

    if (difference == 1) {
      player = player.copyWith(
        streak: player.streak + 1,
        lastActiveDate: today.toIso8601String(),
      );

      savePlayer();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔥 Streak increased to ${player.streak} days!'),
          ),
        );
      });
    }

    if (difference > 1) {
      player = player.copyWith(
        streak: 1,
        lastActiveDate: today.toIso8601String(),
      );

      savePlayer();
    }
  }

  void checkDailyQuestReset() {
    final today = DateTime.now();

    final todayString = '${today.year}-${today.month}-${today.day}';

    if (player.lastQuestResetDate != todayString) {
      quests = [
        const DailyQuest(
          title: 'Drink Water',
          target: 5,
          rewardXp: 50,
          progress: 0,
        ),
        const DailyQuest(
          title: 'Workout',
          target: 1,
          rewardXp: 25,
          progress: 0,
        ),
        const DailyQuest(title: 'Walk', target: 1, rewardXp: 25, progress: 0),
        const DailyQuest(
          title: 'Meditate',
          target: 1,
          rewardXp: 25,
          progress: 0,
        ),
      ];

      player = player.copyWith(
        lastQuestResetDate: todayString,

        waterQuestProgress: 0,
        workoutQuestProgress: 0,
        walkQuestProgress: 0,
        meditateQuestProgress: 0,
      );

      savePlayer();
    }
  }

  void updateAchievements() {
    final achievements = AchievementService.checkAchievements(
      waterCount: player.waterCount,
      workoutCount: player.workoutCount,
      walkCount: player.walkCount,
      meditationCount: player.meditationCount,
      streak: player.streak,
      level: LevelService.calculateLevel(player.xp),
      gold: player.gold,
      bossDefeatCount: player.bossDefeatCount,
      defeatedBosses: player.defeatedBosses,
    );

    player = player.copyWith(
      achievements: {...player.achievements, ...achievements}.toList(),
    );
  }

  @override
  void initState() {
    super.initState();

    player = widget.player;
    featureFlags = FeatureFlagService(widget.session.dartStream);

    _loadFlags();

    checkDailyStreak();

    quests = [
      DailyQuest(
        title: 'Drink Water',
        target: 5,
        rewardXp: 50,
        progress: player.waterQuestProgress,
      ),

      DailyQuest(
        title: 'Workout',
        target: 1,
        rewardXp: 25,
        progress: player.workoutQuestProgress,
      ),

      DailyQuest(
        title: 'Walk',
        target: 1,
        rewardXp: 25,
        progress: player.walkQuestProgress,
      ),

      DailyQuest(
        title: 'Meditate',
        target: 1,
        rewardXp: 25,
        progress: player.meditateQuestProgress,
      ),
    ];

    checkDailyQuestReset();
    updateAchievements();
  }

  void updateQuest(String title) {
    setState(() {
      quests = quests.map((quest) {
        if (quest.title == title && !quest.completed) {
          final updated = quest.copyWith(progress: quest.progress + 1);

          if (updated.title == 'Drink Water') {
            player = player.copyWith(waterQuestProgress: updated.progress);
          }

          if (updated.title == 'Workout') {
            player = player.copyWith(workoutQuestProgress: updated.progress);
          }

          if (updated.title == 'Walk') {
            player = player.copyWith(walkQuestProgress: updated.progress);
          }

          if (updated.title == 'Meditate') {
            player = player.copyWith(meditateQuestProgress: updated.progress);
          }

          if (updated.completed) {
            final oldXp = player.xp;

            player = player.copyWith(xp: player.xp + updated.rewardXp);

            if (LevelService.didLevelUp(oldXp, player.xp)) {
              player = player.copyWith(gold: player.gold + 50);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🎉 LEVEL UP! +50 Gold')),
              );
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Quest Complete! +${updated.rewardXp} XP'),
              ),
            );
          }

          return updated;
        }

        return quest;
      }).toList();
    });

    savePlayer();
  }

  void gainXp(int amount) {
    setState(() {
      player = player.copyWith(xp: player.xp + amount);
    });
  }

  void _drinkWater() {
    final xpReward = featureFlags.enabled("doublexp") ? 20 : 10;

    setState(() {
      player = player.copyWith(
        waterCount: player.waterCount + 1,
        xp: player.xp + xpReward,
        gold: player.gold + 5,
        vitality: player.vitality + 1,
      );
    });

    updateQuest('Drink Water');

    updateAchievements();
    savePlayer();
  }

  void _workout() {
    final xpReward = featureFlags.enabled("doublexp") ? 50 : 25;

    setState(() {
      player = player.copyWith(
        workoutCount: player.workoutCount + 1,
        xp: player.xp + xpReward,
        gold: player.gold + 10,
        strength: player.strength + 1,
      );
    });

    updateQuest('Workout');

    updateAchievements();
    savePlayer();
  }

  void _walk() {
    final xpReward = featureFlags.enabled("doublexp") ? 30 : 15;

    setState(() {
      player = player.copyWith(
        walkCount: player.walkCount + 1,
        xp: player.xp + xpReward,
        gold: player.gold + 5,
        agility: player.agility + 1,
      );
    });

    updateQuest('Walk');

    updateAchievements();
    savePlayer();
  }

  void _meditate() {
    final xpReward = featureFlags.enabled("doublexp") ? 40 : 20;

    setState(() {
      player = player.copyWith(
        meditationCount: player.meditationCount + 1,
        xp: player.xp + xpReward,
        gold: player.gold + 5,
        wisdom: player.wisdom + 1,
      );
    });

    updateQuest('Meditate');

    updateAchievements();
    savePlayer();
  }

  void _claimDailyReward() {
    if (RpgService.isRewardClaimedToday(player)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daily reward already claimed.')),
      );
      return;
    }

    final rewardDay = player.loginRewardDay.clamp(1, 7);

    setState(() {
      if (rewardDay == 7) {
        player = player.copyWith(
          inventory: [...player.inventory, RpgService.epicChest],
          lastRewardClaimDate: RpgService.todayKey(),
          loginRewardDay: 1,
        );
      } else {
        player = player.copyWith(
          gold: player.gold + RpgService.rewardAmountForDay(rewardDay),
          lastRewardClaimDate: RpgService.todayKey(),
          loginRewardDay: rewardDay + 1,
        );
      }

      updateAchievements();
    });

    savePlayer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Claimed ${RpgService.rewardLabelForDay(rewardDay)}.'),
      ),
    );
  }

  void _purchaseItem(String itemName) {
    final item = RpgService.itemByName(itemName);

    if (player.gold < item.cost) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not enough gold.')));
      return;
    }

    setState(() {
      player = player.copyWith(
        gold: player.gold - item.cost,
        inventory: [...player.inventory, item.name],
      );

      updateAchievements();
    });

    savePlayer();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${item.name} purchased.')));
  }

  void _useItem(String itemName) {
    if (!RpgService.isConsumable(itemName)) return;

    final inventory = [...player.inventory];
    final removed = inventory.remove(itemName);
    if (!removed) return;

    final xpReward = itemName == RpgService.smallXpPotion ? 50 : 200;

    setState(() {
      player = player.copyWith(xp: player.xp + xpReward, inventory: inventory);

      updateAchievements();
    });

    savePlayer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Used $itemName for +$xpReward XP.')),
    );
  }

  void _equipItem(String itemName) {
    if (!player.inventory.contains(itemName)) return;

    setState(() {
      if (itemName == RpgService.ironSword) {
        player = player.copyWith(equippedWeapon: itemName);
      } else if (itemName == RpgService.steelArmor) {
        player = player.copyWith(equippedArmor: itemName);
      } else if (itemName == RpgService.magicRing) {
        player = player.copyWith(equippedAccessory: itemName);
      }
    });

    savePlayer();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Equipped $itemName.')));
  }

  void _openChest(String itemName) {
    if (!RpgService.isChest(itemName)) return;

    final inventory = [...player.inventory];
    final removed = inventory.remove(itemName);
    if (!removed) return;

    setState(() {
      player = player.copyWith(
        gold: player.gold + 150,
        inventory: [...inventory, RpgService.largeXpPotion],
      );

      updateAchievements();
    });

    savePlayer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Epic Chest opened! +150 Gold and Large XP Potion'),
      ),
    );
  }

  void _selectBoss(String bossName) {
    final boss = RpgService.bossByName(bossName);

    setState(() {
      player = player.copyWith(
        activeBossName: boss.name,
        activeBossHp: boss.hp,
      );
    });

    savePlayer();
  }

  void _attackBoss() {
    final activeBossName = player.activeBossName;
    if (activeBossName == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a boss first.')));
      return;
    }

    final boss = RpgService.bossByName(activeBossName);
    final damage = RpgService.playerPower(player);
    final nextHp = player.activeBossHp - damage;

    setState(() {
      if (nextHp <= 0) {
        final defeatedBosses = {...player.defeatedBosses, boss.name}.toList();

        player = player.copyWith(
          xp: player.xp + boss.rewardXp,
          gold: player.gold + boss.rewardGold,
          bossDefeatCount: player.bossDefeatCount + 1,
          defeatedBosses: defeatedBosses,
          clearActiveBoss: true,
        );

        updateAchievements();
      } else {
        player = player.copyWith(activeBossHp: nextHp);
      }
    });

    savePlayer();

    if (nextHp <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${boss.name} defeated! +${boss.rewardXp} XP, +${boss.rewardGold} Gold',
          ),
        ),
      );
    }
  }

  void _openInventory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InventoryScreen(
          player: player,
          getPlayer: () => player,
          onUseItem: _useItem,
          onEquipItem: _equipItem,
          onOpenChest: _openChest,
          onGoToShop: () {
            Navigator.pop(context);
            setState(() => _selectedTab = 4);
          },
        ),
      ),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(session: widget.session, player: player),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeDashboardTab(
        player: player,
        onClaimDailyReward: _claimDailyReward,
        onOpenInventory: _openInventory,
        featureFlags: featureFlags,
      ),
      QuestsDashboardTab(
        quests: quests,
        onDrinkWater: _drinkWater,
        onWorkout: _workout,
        onWalk: _walk,
        onMeditate: _meditate,
      ),
      HeroDashboardTab(
        player: player,
        onUseItem: _useItem,
        onEquipItem: _equipItem,
        onOpenChest: _openChest,
        onOpenInventory: _openInventory,
      ),
      AchievementsDashboardTab(achievements: player.achievements),
      ShopDashboardTab(player: player, onPurchaseItem: _purchaseItem),
      BossBattleDashboardTab(
        player: player,
        onSelectBoss: _selectBoss,
        onAttackBoss: _attackBoss,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitQuest'),
        actions: [
          IconButton(
            onPressed: _openProfile,
            icon: const Icon(Icons.account_circle),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedTab, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) => setState(() => _selectedTab = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Quests'),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Hero'),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Achievements',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Shop'),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_martial_arts),
            label: 'Battle',
          ),
        ],
      ),
    );
  }
}
