import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  late final TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) return;

    setState(() => _loading = true);

    try {
      await supabase.auth.resetPasswordForEmail(
        _emailController.text.trim(),
        redirectTo: 'https://commercia-aarau.ch/app_password_reset.html',
      );

      if (!mounted) return;
      setState(() {
        _loading = false;
        _sent = true;
      });
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
      appBar: AppBar(
        title: const Text('Passwort vergessen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: Container(
          width: 600,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _sent ? _buildSentView() : _buildFormView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
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
            'Gib deine Email-Adresse ein. Wir senden dir einen Link, '
            'um dein Passwort zurückzusetzen.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email benötigt';
              }
              return null;
            },
            controller: _emailController,
            decoration: const InputDecoration(label: Text("Email")),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 25.0),
          _loading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : ElevatedButton(
                  onPressed: _sendResetEmail,
                  child: const Text(
                    "Link senden",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSentView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/icons/logo.png',
          color: Theme.of(context).colorScheme.onSurface,
          height: 200,
        ),
        const SizedBox(height: 50),
        Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 20),
        const Text(
          'Mail gesendet!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        const Text(
          'Falls ein Konto mit dieser Email existiert, haben wir dir einen '
          'Link zum Zurücksetzen des Passworts zugeschickt. '
          'Prüfe auch den Spam-Ordner.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => context.go('/'),
          child: const Text(
            "Zurück zum Login",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}