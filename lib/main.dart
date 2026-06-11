import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'models/player_data.dart';
import 'screens/character_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/cloud_save_service.dart';
import 'state/session.dart';
import 'services/feature_flag_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const FitQuestApp());
}

class FitQuestApp extends StatefulWidget {
  const FitQuestApp({super.key});

  @override
  State<FitQuestApp> createState() => _FitQuestAppState();
}

class _FitQuestAppState extends State<FitQuestApp> {
  final Session _session = Session();

  Future<PlayerData?>? _playerFuture;

  @override
  void initState() {
    super.initState();

    _session.addListener(() {
      if (_session.status == SessionStatus.signedIn && _playerFuture == null) {
        _playerFuture = _loadPlayer();
      }

      if (_session.status != SessionStatus.signedIn) {
        _playerFuture = null;
      }

      setState(() {});
    });
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  Future<PlayerData?> _loadPlayer() async {
    final cloudSave = CloudSaveService(_session.dartStream);

    final player = await cloudSave.loadPlayer(
      userId: _session.userId!,
      tenantId: _session.tenantId!,
    );

    final featureFlags = FeatureFlagService(_session.dartStream);

    await featureFlags.load();

    debugPrint(featureFlags.flags.toString());

    return player;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitQuest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: _session.status != SessionStatus.signedIn
          ? LoginScreen(session: _session)
          : Builder(
              builder: (context) {
                _playerFuture ??= _loadPlayer();

                return FutureBuilder<PlayerData?>(
                  future: _playerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final player = snapshot.data;

                    if (player == null || player.heroClass.trim().isEmpty) {
                      return CharacterSetupScreen(
                        session: _session,
                        onCharacterCreated: () {
                          _playerFuture = null;

                          setState(() {});
                        },
                      );
                    }

                    return HomeScreen(session: _session, player: player);
                  },
                );
              },
            ),
    );
  }
}
