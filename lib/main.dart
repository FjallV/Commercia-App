import 'package:commercia/business/misc.dart';
import 'package:commercia/data/models/event_model.dart';
import 'package:commercia/data/models/song_model.dart';
import 'package:commercia/presentation/screens/auth_screen.dart';
import 'package:commercia/presentation/screens/event_details_screen.dart';
import 'package:commercia/presentation/screens/home_screen.dart';
import 'package:commercia/presentation/screens/pdf_screen.dart';
import 'package:commercia/presentation/screens/settings_screen.dart';
import 'package:commercia/presentation/screens/song_details_screen.dart';
import 'package:commercia/presentation/styles/themes.dart';
import 'package:commercia/presentation/widgets/screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pwa_install/pwa_install.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// GoRouter configuration
final _router = goRouter();

// ThemeMode notifier
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  SharedPref.getThemeMode().then((mode) {
    themeNotifier.value = mode;
  });

  runApp(CommerciaApp()); //const
}

class CommerciaApp extends StatelessWidget with ChangeNotifier {
  CommerciaApp({super.key}); //const

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.blue, //or set color with: Color(0xFF0000FF)
    //   systemNavigationBarColor: Colors.white,
    // ));
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp.router(
          routerConfig: _router,
          themeMode: themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
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
