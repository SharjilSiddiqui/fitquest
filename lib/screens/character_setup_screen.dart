import 'package:flutter/material.dart';

import '../models/player_data.dart';
import '../services/cloud_save_service.dart';
import '../state/session.dart';

class CharacterSetupScreen extends StatelessWidget {
  const CharacterSetupScreen({
    super.key,
    required this.session,
    required this.onCharacterCreated,
  });

  final Session session;
  final VoidCallback onCharacterCreated;

  Future<void> _createCharacter(BuildContext context, String heroClass) async {
    final cloudSave = CloudSaveService(session.dartStream);

    final player = PlayerData(
      heroClass: heroClass,
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

      streak: 1,
      lastActiveDate: DateTime.now().toIso8601String(),
      loginRewardDay: 1,

      inventory: const [],

      activeBossHp: 0,
      bossDefeatCount: 0,
      defeatedBosses: const [],

      achievements: const [],
    );

    try {
      await cloudSave.savePlayer(
        userId: session.userId!,
        tenantId: session.tenantId!,
        player: player,
      );

      if (!context.mounted) return;

      onCharacterCreated();
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final classes = ['warrior', 'ranger', 'monk', 'mage'];

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Hero')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Choose Your Class',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...classes.map(
              (heroClass) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FilledButton(
                  onPressed: () => _createCharacter(context, heroClass),
                  child: Text(heroClass.toUpperCase()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
