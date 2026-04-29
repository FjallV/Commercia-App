import 'package:commercia/business/misc.dart';
import 'package:commercia/data/models/event_model.dart';
import 'package:commercia/data/models/song_model.dart';
import 'package:commercia/data/models/member_model.dart';
import 'package:commercia/presentation/screens/auth_screen.dart';
import 'package:commercia/presentation/screens/event_details_screen.dart';
import 'package:commercia/presentation/screens/member_details_screen.dart';
import 'package:commercia/presentation/screens/home_screen.dart';
import 'package:commercia/presentation/screens/pdf_screen.dart';
import 'package:commercia/presentation/screens/settings_screen.dart';
import 'package:commercia/presentation/screens/song_details_screen.dart';
import 'package:commercia/presentation/styles/themes.dart';
import 'package:commercia/data/repositories/member_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pwa_install/pwa_install.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:commercia/services/version_check_service.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// GoRouter configuration
final _router = goRouter();

// ThemeMode notifier
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final VersionCheckService versionCheckService = VersionCheckService();

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Alte Service Worker abräumen — wir brauchen sie nicht
  await versionCheckService.cleanupServiceWorkers();

  await initializeDateFormatting('de_CH');
  // TODO: Look at dotenv
  // https://supabase.com/docs/guides/api/api-keys
  // await dotenv.load();
  // await Supabase.initialize(
  //     url: dotenv.env['SUPABASE_URL']!, anonKey: dotenv.env['SUPABASE_KEY']!);

  await Supabase.initialize(
      url: 'https://kjapiuoilygzhdbmjqdt.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtqYXBpdW9pbHlnemhkYm1qcWR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA0OTc4NTAsImV4cCI6MjA1NjA3Mzg1MH0.POj6BxUlnkVHCs6Z8kD0cHcqCzFdHY6hOdVfVswq4Kg');

  // Capture PWA install
  PWAInstall().setup(installCallback: () {
    debugPrint('APP INSTALLED!');
  });

  // SharedPref.getThemeMode().then((mode) {
  //   themeNotifier.value = mode;
  // });

  final mode = await SharedPref.getThemeMode();
  themeNotifier.value = mode;

  runApp(CommerciaApp()); //const
}

class CommerciaApp extends StatefulWidget {
  const CommerciaApp({super.key});

  @override
  State<CommerciaApp> createState() => _CommerciaAppState();
}

class _CommerciaAppState extends State<CommerciaApp> {
  @override
  void initState() {
    super.initState();
    versionCheckService.start();
    versionCheckService.updateAvailable.addListener(_onUpdateAvailable);
  }

  @override
  void dispose() {
    versionCheckService.updateAvailable.removeListener(_onUpdateAvailable);
    versionCheckService.stop();
    super.dispose();
  }

void _onUpdateAvailable() {
  if (!versionCheckService.updateAvailable.value) return;

  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: const Text('Eine neue Version ist verfügbar.'),
      duration: const Duration(days: 1),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'Aktualisieren',
        onPressed: () {
          // Snackbar weg, Notifier reset (für den Fall dass der Reload fehlschlägt)
          scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
          versionCheckService.updateAvailable.value = false;
          
          versionCheckService.reloadAndUpdate();
        },
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp.router(
          routerConfig: _router,
          themeMode: themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          scaffoldMessengerKey: scaffoldMessengerKey,
        );
      },
    );
  }
}

// GoRouter configuration
GoRouter goRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        name: 'auth',
        path: '/',
        builder: (context, state) => AuthScreen(),
      ),
      GoRoute(
        name: 'home',
        path: '/home',
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        name: 'event_details',
        path: '/events',
        builder: (context, state) {
          EventModel event = state.extra as EventModel;
          return EventDetails(
            event: event,
          );
        },
      ),
      GoRoute(
        name: 'member_details',
        path: '/members/details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final allMembers = state.extra as List<MemberModel>?;
          // If allMembers is in memory (normal nav), find member there to avoid a fetch.
          // On web refresh, allMembers will be null and we show a loading screen.
          if (allMembers != null) {
            final member = allMembers.firstWhere((m) => m.id == id);
            return MemberDetails(member: member, allMembers: allMembers);
          }
          // Web refresh / deep link: fetch from Supabase.
          return FutureBuilder<MemberModel>(
            future: MemberRepository().fetchMemberById(id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return MemberDetails(member: snapshot.data!, allMembers: const []);
              }
              if (snapshot.hasError) {
                return Scaffold(body: Center(child: Text('Fehler beim Laden.')));
              }
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            },
          );
        },
      ),
      GoRoute(
        name: 'song_details',
        path: '/songs',
        builder: (context, state) {
          SongModel song = state.extra as SongModel;
          return SongDetails(
            song: song,
          );
        },
      ),
      GoRoute(
        name: 'settings',
        path: '/settings',
        builder: (context, state) {
          return SettingsScreen();
        },
      ),
      GoRoute(
        name: 'pdf',
        path: '/pdf',
        builder: (context, state) {
          Map<String, dynamic> data = state.extra as Map<String, dynamic>;
          return PdfScreen(name: data['name'], path: data['path']);
        },
      ),
    ],
  );
}