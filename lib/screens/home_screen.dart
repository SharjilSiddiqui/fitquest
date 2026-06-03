import 'package:flutter/material.dart';

import '../state/session.dart';
import '../models/player_data.dart';
import '../services/xp_service.dart';
import '../services/cloud_save_service.dart';
import '../models/daily_quest.dart';
import '../services/level_service.dart';

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

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hero Class: ${player.heroClass}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Text('Level: ${XpService.levelFromXp(player.xp)}'),
              Text('XP: ${player.xp}'),
              Text('🪙 Gold: ${player.gold}'),

              const SizedBox(height: 8),

              Text(
                '🔥 Streak: ${player.streak} Days',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              LinearProgressIndicator(
                value: XpService.progressToNextLevel(player.xp),
              ),

              const SizedBox(height: 8),

              Text('${XpService.currentLevelXp(player.xp)}/100 XP'),

              const SizedBox(height: 24),

              Text('Water: ${player.waterCount}'),
              Text('Workouts: ${player.workoutCount}'),
              Text('Walks: ${player.walkCount}'),
              Text('Meditation: ${player.meditationCount}'),

              const SizedBox(height: 20),

              const SizedBox(height: 24),

              const Text(
                'Daily Quests',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              ...quests.map(
                (quest) => ListTile(
                  leading: Icon(
                    quest.completed
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                  ),
                  title: Text(quest.title),
                  subtitle: Text('${quest.progress}/${quest.target}'),
                  trailing: Text('+${quest.rewardXp} XP'),
                ),
              ),

              FilledButton(
                onPressed: () async {
                  setState(() {
                    player = player.copyWith(
                      waterCount: player.waterCount + 1,
                      xp: player.xp + 10,
                      gold: player.gold + 5,
                    );
                  });

                  updateQuest('Drink Water');
                },
                child: const Text('💧 Drink Water (+10 XP)'),
              ),

              const SizedBox(height: 10),

              FilledButton(
                onPressed: () async {
                  setState(() {
                    player = player.copyWith(
                      workoutCount: player.workoutCount + 1,
                      xp: player.xp + 25,
                      gold: player.gold + 10,
                    );
                  });

                  updateQuest('Workout');
                },
                child: const Text('🏋 Workout (+25 XP)'),
              ),

              const SizedBox(height: 10),

              FilledButton(
                onPressed: () async {
                  setState(() {
                    player = player.copyWith(
                      walkCount: player.walkCount + 1,
                      xp: player.xp + 15,
                      gold: player.gold + 5,
                    );
                  });

                  updateQuest('Walk');
                },
                child: const Text('🚶 Walk (+15 XP)'),
              ),

              const SizedBox(height: 10),

              FilledButton(
                onPressed: () async {
                  setState(() {
                    player = player.copyWith(
                      meditationCount: player.meditationCount + 1,
                      xp: player.xp + 20,
                      gold: player.gold + 5,
                    );
                  });

                  updateQuest('Meditate');
                },
                child: const Text('🧘 Meditate (+20 XP)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
