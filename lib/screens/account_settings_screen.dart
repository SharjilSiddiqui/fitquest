import 'package:flutter/material.dart';

import '../services/auth_me_service.dart';
import '../state/session.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key, required this.session});

  final Session session;

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late Future<Map<String, dynamic>> meFuture;

  late AuthMeService authService;

  final TextEditingController displayNameController = TextEditingController();

  bool saving = false;

  @override
  void initState() {
    super.initState();

    authService = AuthMeService(widget.session.dartStream);

    meFuture = authService.loadMe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account Settings")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: meFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final me = snapshot.data!;

          if (displayNameController.text.isEmpty) {
            displayNameController.text = me["displayName"]?.toString() ?? "";
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text("Email"),
                  subtitle: Text(me["email"]?.toString() ?? ""),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person),
                          SizedBox(width: 8),
                          Text(
                            "Display Name",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: displayNameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter display name",
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: saving
                              ? null
                              : () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );

                                  setState(() {
                                    saving = true;
                                  });

                                  try {
                                    await authService.updateDisplayName(
                                      displayNameController.text.trim(),
                                    );

                                    if (!mounted) return;

                                    setState(() {
                                      meFuture = authService.loadMe();
                                    });

                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text("Display name updated!"),
                                      ),
                                    );
                                  } catch (e) {
                                    messenger.showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }

                                  if (!mounted) return;

                                  setState(() {
                                    saving = false;
                                  });
                                },
                          child: saving
                              ? const CircularProgressIndicator()
                              : const Text("Save"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text("User ID"),
                  subtitle: Text(me["id"]?.toString() ?? ""),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text("UID"),
                  subtitle: Text(me["uid"]?.toString() ?? ""),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text("Phone"),
                  subtitle: Text(me["phone"]?.toString() ?? "Not set"),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text("Language"),
                  subtitle: Text(me["language"]?.toString() ?? "Not set"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
