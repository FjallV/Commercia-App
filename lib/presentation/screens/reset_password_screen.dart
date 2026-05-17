import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _passwordController = TextEditingController();
  final _passwordCheckController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordCheckController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) return;

    // Sicherstellen, dass eine Recovery-Session aktiv ist
    final session = supabase.auth.currentSession;
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Kein gültiger Reset-Link. Bitte fordere einen neuen an.",
          ),
        ),
      );
      context.go('/forgot-password');
      return;
    }

    setState(() => _loading = true);

    try {
      await supabase.auth.updateUser(
        UserAttributes(password: _passwordController.text.trim()),
      );

      if (!mounted) return;

      // Ausloggen, damit der Nutzer sich frisch einloggt
      await supabase.auth.signOut();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwort erfolgreich geändert. Bitte einloggen."),
        ),
      );
      context.go('/');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fehler: $e"),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Neues Passwort')),
      body: Center(
        child: Container(
          width: 600,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/logo.png',
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 200,
                    ),
                    const SizedBox(height: 50),
                    const Text(
                      'Wähle ein neues Passwort.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Passwort benötigt';
                        } else if (value.length < 6) {
                          return 'Mindestens 6 Zeichen';
                        }
                        return null;
                      },
                      controller: _passwordController,
                      decoration: InputDecoration(
                        label: const Text("Neues Passwort"),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_passwordVisible,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Passwort bestätigen';
                        } else if (value != _passwordController.text) {
                          return 'Passwörter stimmen nicht überein';
                        }
                        return null;
                      },
                      controller: _passwordCheckController,
                      decoration: const InputDecoration(
                        label: Text("Passwort wiederholen"),
                      ),
                      obscureText: !_passwordVisible,
                    ),
                    const SizedBox(height: 25.0),
                    _loading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _updatePassword,
                            child: const Text(
                              "Passwort speichern",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}