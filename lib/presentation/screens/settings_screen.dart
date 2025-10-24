import 'package:commercia/business/misc.dart';
import 'package:commercia/main.dart';
import 'package:commercia/presentation/widgets/screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pwa_install/pwa_install.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode themeMode = themeNotifier.value;

  @override
  Widget build(BuildContext context) {
    bool installPromptEnabled;
    String installSubtitle;
    if (PWAInstall().installPromptEnabled == true) {
      installPromptEnabled = true;
      installSubtitle = 'Installiere die App auf deinem Gerät';
    } else {
      installPromptEnabled = false;
      installSubtitle =
          'App ist bereits installiert oder kann nicht installiert werden';
    }

    return Scaffold(
      appBar: appBarDetails(context, 'Einstellungen'),
      body: Center(
        child: ListView(
          // Important: Remove any padding from the ListView.
          //TODO: Add username/cerevis
          padding: EdgeInsets.zero,
          children: [
            // Theme selection tile
            ListTile(
              title: Text("Thema"),
              leading: Icon(Icons.color_lens),
              subtitle: Text(
                themeMode == ThemeMode.system
                    ? "System"
                    : themeMode == ThemeMode.light
                        ? "Hell"
                        : "Dunkel",
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => ThemeBottomSheet(
                    selected: themeMode,
                    onChanged: (mode) {
                      SharedPref.setThemeMode(mode); // <-- Save to SharedPref
                      themeNotifier.value = mode;
                      setState(() {
                        themeMode = mode;
                      });
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('App installieren'),
              subtitle: Text(installSubtitle),
              leading: Icon(
                Icons.install_mobile,
              ),
              onTap: () {
                // Install pwa
                if (PWAInstall().installPromptEnabled == true) {
                  PWAInstall().promptInstall_();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Hello, Snackbar!'),
                  ));
                }
              },
              enabled: installPromptEnabled,
            ),
            ListTile(
              title: const Text('Abmelden'),
              leading: Icon(
                Icons.logout,
              ),
              onTap: () async {
                // Logout user
                await Supabase.instance.client.auth.signOut();
                //context.pushNamed('auth');
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Abmeldung erfolgreich'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom sheet widget for theme selection
class ThemeBottomSheet extends StatelessWidget {
  final ThemeMode selected;
  final ValueChanged<ThemeMode> onChanged;
  const ThemeBottomSheet(
      {required this.selected, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<ThemeMode>(
            title: Row(
              children: [
                Icon(Icons.phone_android,
                    color: Theme.of(context).colorScheme.primary),
                SizedBox(width: 8),
                Text('System'),
              ],
            ),
            value: ThemeMode.system,
            groupValue: selected,
            onChanged: (mode) {
              if (mode != null) onChanged(mode);
            },
          ),
          RadioListTile<ThemeMode>(
            title: Row(
              children: [
                Icon(Icons.light_mode,
                    color: Theme.of(context).colorScheme.primary),
                SizedBox(width: 8),
                Text('Hell'),
              ],
            ),
            value: ThemeMode.light,
            groupValue: selected,
            onChanged: (mode) {
              if (mode != null) onChanged(mode);
            },
          ),
          RadioListTile<ThemeMode>(
            title: Row(
              children: [
                Icon(Icons.dark_mode,
                    color: Theme.of(context).colorScheme.primary),
                SizedBox(width: 8),
                Text('Dunkel'),
              ],
            ),
            value: ThemeMode.dark,
            groupValue: selected,
            onChanged: (mode) {
              if (mode != null) onChanged(mode);
            },
          ),
        ],
      ),
    );
  }
}
