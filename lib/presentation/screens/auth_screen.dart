import 'package:commercia/main.dart';
import 'package:commercia/app_state.dart';
import 'package:commercia/data/repositories/member_repository.dart';
import 'package:commercia/presentation/screens/home_screen.dart';
import 'package:commercia/presentation/screens/splash_screen.dart';
import 'package:commercia/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final MemberRepository _memberRepository = MemberRepository();

  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getAuth();
  }

  Future<void> _getAuth() async {
    await _handleUserChange(supabase.auth.currentUser);
    supabase.auth.onAuthStateChange.listen((event) async {
      await _handleUserChange(event.session?.user);
    });
  }

  Future<void> _handleUserChange(User? user) async {
    if (user == null) {
      AppState.instance.clear();
      setState(() {
        _user = null;
        _loading = false;
      });
      FlutterNativeSplash.remove();
      return;
    }

    try {
      final member = await _memberRepository.getMemberById(user.id);
      AppState.instance.setMember(member);

      // if (mounted && member != null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Willkommen, ${member.cerevis}!')),
      //   );
      // }
    } catch (e) {
      AppState.instance.clear();
      debugPrint('Could not fetch member data: $e');
    }

    setState(() {
      _user = user;
      _loading = false;
    });
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SplashScreen();
    return _user == null ? const StartPage() : const HomeScreen();
  }
}
