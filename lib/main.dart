import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'models/player_data.dart';
import 'screens/character_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/cloud_save_service.dart';
import 'state/session.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
    // ignore: avoid_print
    print('[Intellitoggle] dotenv loaded');
  } catch (e) {
    // ignore: avoid_print
    print(
      '[Intellitoggle] dotenv load failed, using dart-defines if present: $e',
    );
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

    return player;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitQuest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          secondary: const Color(0xFFEF6C00),
          tertiary: const Color(0xFF1565C0),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7FAF6),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 2,
          backgroundColor: Color(0xFFF7FAF6),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(64, 48),
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
