import 'package:flutter/material.dart';

import '../state/session.dart';
import '../models/player_data.dart';
import '../services/cloud_save_service.dart';
import '../models/daily_quest.dart';
import '../services/level_service.dart';
import '../widgets/fitquest_dashboard.dart';

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
  int _selectedTab = 0;

  Future<void> savePlayer() async {
    final api = widget.session.api!;

    final cloudSave = CloudSaveService(api);

    await cloudSave.savePlayer(
      userId: widget.session.userId!,
      tenantId: widget.session.tenantId!,
      player: player,
    );
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

  @override
  void initState() {
    super.initState();

    player = widget.player;

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
    setState(() {
      player = player.copyWith(
        waterCount: player.waterCount + 1,
        xp: player.xp + 10,
        gold: player.gold + 5,
      );
    });

    updateQuest('Drink Water');
  }

  void _workout() {
    setState(() {
      player = player.copyWith(
        workoutCount: player.workoutCount + 1,
        xp: player.xp + 25,
        gold: player.gold + 10,
      );
    });

    updateQuest('Workout');
  }

  void _walk() {
    setState(() {
      player = player.copyWith(
        walkCount: player.walkCount + 1,
        xp: player.xp + 15,
        gold: player.gold + 5,
      );
    });

    updateQuest('Walk');
  }

  void _meditate() {
    setState(() {
      player = player.copyWith(
        meditationCount: player.meditationCount + 1,
        xp: player.xp + 20,
        gold: player.gold + 5,
      );
    });

    updateQuest('Meditate');
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeDashboardTab(player: player),
      QuestsDashboardTab(
        quests: quests,
        onDrinkWater: _drinkWater,
        onWorkout: _workout,
        onWalk: _walk,
        onMeditate: _meditate,
      ),
      HeroDashboardTab(player: player),
      const AchievementsDashboardTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitQuest'),
        actions: [
          IconButton(
            onPressed: widget.session.signOut,
            icon: const Icon(Icons.logout),
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
            label: 'Awards',
          ),
        ],
      ),
    );
  }
}
