import 'package:commercia/business/utils.dart';
import 'package:commercia/main.dart';
import 'package:commercia/presentation/widgets/screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pwa_install/pwa_install.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:commercia/services/version_check_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode themeMode = themeNotifier.value;

  // Versteckter Diagnose-Trigger via 5-fach-Tap
  int _diagnoseTapCount = 0;
  DateTime? _lastTap;

  void _registerDiagnoseTap() {
    final now = DateTime.now();

    // Reset wenn letzter Tap länger als 2 Sekunden her
    if (_lastTap != null &&
        now.difference(_lastTap!) > const Duration(seconds: 2)) {
      _diagnoseTapCount = 0;
    }

    _lastTap = now;
    _diagnoseTapCount++;

    if (_diagnoseTapCount >= 5) {
      _diagnoseTapCount = 0;
      _showDiagnose();
    }
  }

  Future<void> _showDiagnose() async {
    // Diagnose direkt holen — geht schnell genug, kein Lade-Kreis nötig
    final info = await versionCheckService.diagnose();

    if (!mounted) return;

    final formatted =
        info.entries.map((e) => '${e.key}:\n${e.value}\n').join('\n');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Diagnose'),
        content: SingleChildScrollView(
          child: SelectableText(
            formatted,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: formatted));
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('In Zwischenablage kopiert')),
              );
            },
            child: const Text('Kopieren'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Schliessen'),
          ),
        ],
      ),
    );
  }

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
          padding: EdgeInsets.zero,
          //TODO: Add username/cerevis
          children: [
            // Theme selection tile
            ListTile(
              title: const Text("Thema"),
              leading: const Icon(Icons.color_lens),
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
                      SharedPref.setThemeMode(mode);
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
              leading: const Icon(Icons.install_mobile),
              onTap: () {
                if (PWAInstall().installPromptEnabled == true) {
                  PWAInstall().promptInstall_();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Hello, Snackbar!'),
                  ));
                }
              },
              enabled: installPromptEnabled,
            ),
            VersionInfoTile(onSecretTap: _registerDiagnoseTap),
            ListTile(
              title: const Text('Abmelden'),
              leading: const Icon(Icons.logout),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Abmeldung erfolgreich'),
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

class VersionInfoTile extends StatelessWidget {
  final VoidCallback? onSecretTap;

  const VersionInfoTile({super.key, this.onSecretTap});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final appVersion = snapshot.hasData ? snapshot.data!.version : '...';
        final buildVersion = VersionCheckService.currentVersion;

        return ListTile(
          leading: const SizedBox(
            height: double.infinity,
            child: Icon(Icons.info_outline),
          ),
          title: const Text('Version'),
          subtitle: Text('App: $appVersion\nBuild: $buildVersion'),
          isThreeLine: true,
          onTap: onSecretTap,
        );
      },
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
                const SizedBox(width: 8),
                const Text('System'),
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
                const SizedBox(width: 8),
                const Text('Hell'),
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
                const SizedBox(width: 8),
                const Text('Dunkel'),
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
