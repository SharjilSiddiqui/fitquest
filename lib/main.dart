import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'models/player_data.dart';
import 'screens/character_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/cloud_save_service.dart';
import 'state/session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  debugPrint('Auth Host: ${dotenv.env['AUTH_HOST']}');
  runApp(const FitQuestApp());
}

class FitQuestApp extends StatefulWidget {
  const FitQuestApp({super.key});

  @override
  State<FitQuestApp> createState() => _FitQuestAppState();
}

class _FitQuestAppState extends State<FitQuestApp> {
  final Session _session = Session();

  @override
  void initState() {
    super.initState();

    _session.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  Future<PlayerData?> _loadPlayer() async {
    debugPrint('LOADING PLAYER');

    final api = _session.api!;

    final cloudSave = CloudSaveService(api);

    final player = await cloudSave.loadPlayer(
      userId: _session.userId!,
      tenantId: _session.tenantId!,
    );

    debugPrint('PLAYER RESULT: ${player?.heroClass}');

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
          : FutureBuilder<PlayerData?>(
              future: _loadPlayer(),
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
                      setState(() {});
                    },
                  );
                }

                return HomeScreen(session: _session, player: player);
              },
            ),
    );
  }
}
