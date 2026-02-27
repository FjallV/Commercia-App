import 'package:commercia/presentation/widgets/screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with TickerProviderStateMixin {
  final SupabaseClient supabase = Supabase.instance.client;
  late final _tabController = TabController(length: 2, vsync: this);

  // Sign In
  bool _signInLoading = false;
  bool _passwordSignInVisible = false;
  final _emailSignInController = TextEditingController();
  final _passwordSignInController = TextEditingController();
  final _formSignInKey = GlobalKey<FormState>();

  // Sign Up
  bool _signUpLoading = false;
  bool _passwordSignUpVisible = false;
  final _codeSignUpController = TextEditingController();
  final _cerevisSignUpController = TextEditingController();
  final _emailSignUpController = TextEditingController();
  final _passwordSignUpController = TextEditingController();
  final _passwordCheckSignUpController = TextEditingController();
  final _formSignUpKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailSignInController.dispose();
    _passwordSignInController.dispose();
    _codeSignUpController.dispose();
    _cerevisSignUpController.dispose();
    _emailSignUpController.dispose();
    _passwordSignUpController.dispose();
    _passwordCheckSignUpController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _passwordSignInVisible = false;
    _passwordSignUpVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Anmelden', icon: Icon(Icons.login)),
            Tab(text: 'Registrieren', icon: Icon(Icons.person_add)),
          ],
        ),
        title: const Text('Commercia App'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SignIn(),
          SignUp(),
        ],
      ),
    );
    // );
  }

  Widget SignIn() {
    return Center(
      child: Container(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formSignInKey,
            child: Padding(
              padding: const EdgeInsets.all(
                20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/icons/logo.png',
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 200,
                  ),
                  SizedBox(height: 100),
                  //Email field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email benötigt';
                      }
                      return null;
                    },
                    controller: _emailSignInController,
                    decoration: const InputDecoration(label: Text("Email")),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 10),
                  //Password field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Passwort benötigt';
                      }
                      return null;
                    },
                    controller: _passwordSignInController,
                    decoration: InputDecoration(
                      label: const Text("Passwort"),
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _passwordSignInVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {
                            _passwordSignInVisible = !_passwordSignInVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_passwordSignInVisible,
                  ),
                  const SizedBox(height: 25.0),
                  //Sign In Button
                  _signInLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            final isValid =
                                _formSignInKey.currentState?.validate();
                            if (isValid != true) {
                              return;
                            }
                            setState(() {
                              _signInLoading = true;
                            });
                            try {
                              await supabase.auth.signInWithPassword(
                                  email: _emailSignInController.text.trim(),
                                  password:
                                      _passwordSignInController.text.trim());
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Fehler beim Anmelden: $e"),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              );
                              setState(() {
                                _signInLoading = false;
                              });
                            }
                          },
                          child: Text(
                            "Anmelden",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget SignUp() {
    return Center(
      child: Container(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formSignUpKey,
            child: Padding(
              padding: const EdgeInsets.all(
                20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Commercia logo
                  Image.asset(
                    'assets/icons/logo.png',
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 200,
                  ),
                  SizedBox(height: 100),
                  //Code field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Code benötigt';
                      } else if (value != 'ErgoBibamus!') {
                        return 'Falscher Code';
                      }
                      return null;
                    },
                    controller: _codeSignUpController,
                    decoration: const InputDecoration(label: Text("Code")),
                  ),
                  SizedBox(height: 10),
                  //Cerevis field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Cerevis benötigt';
                      }
                      return null;
                    },
                    controller: _cerevisSignUpController,
                    decoration: const InputDecoration(label: Text("Cerevis")),
                  ),
                  SizedBox(height: 10),
                  //Email field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email benötigt';
                      }
                      return null;
                    },
                    controller: _emailSignUpController,
                    decoration: const InputDecoration(label: Text("Email")),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 10),
                  //Password field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Passwort benötigt';
                      }
                      return null;
                    },
                    controller: _passwordSignUpController,
                    decoration: InputDecoration(
                      label: const Text("Passwort"),
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _passwordSignUpVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {
                            _passwordSignUpVisible = !_passwordSignUpVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_passwordSignUpVisible,
                  ),
                  SizedBox(height: 10),
                  //Password Check field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Passwort bestätigen';
                      } else if (value != _passwordSignUpController.text) {
                        return 'Passwörter stimmen nicht überein';
                      }
                      return null;
                    },
                    controller: _passwordCheckSignUpController,
                    decoration: InputDecoration(
                      label: const Text("Passwort wiederholen"),
                    ),
                    obscureText: !_passwordSignUpVisible,
                  ),
                  const SizedBox(height: 25.0),
                  //Sign In Button
                  _signUpLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            final isValid =
                                _formSignUpKey.currentState?.validate();
                            if (isValid != true) {
                              return;
                            }
                            setState(() {
                              _signUpLoading = true;
                            });
                            try {
                              // Step 1: Check if cerevis exists
                              final cerevisResult = await supabase
                                  .from('members')
                                  .select()
                                  .ilike('cerevis', _cerevisSignUpController.text.trim());

                              if (cerevisResult.isEmpty) {
                                throw 'Cerevis nicht gefunden';
                              }

                              // Step 2: Check if cerevis is already linked to a user
                              final existingUserId = cerevisResult.first['user_id'];
                              if (existingUserId != null && existingUserId.toString().isNotEmpty) {
                                throw 'Cerevis bereits mit User verlinkt';
                              }

                              // Step 3: Sign up with Supabase
                              final response = await supabase.auth.signUp(
                                email: _emailSignUpController.text.trim(),
                                password: _passwordSignUpController.text.trim(),
                                emailRedirectTo:
                                    'https://commercia-aarau.ch/app_confirmation.html',
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Bestätigungsmail gesendet"),
                                ),
                              );

                              final user = response.user;

                              // Step 4: Link the user to the cerevis
                              await supabase.from('members').update({
                                'user_id': user?.id,
                              }).ilike('cerevis', _cerevisSignUpController.text.trim());

                              // Reset the tab to SignIn
                              _tabController.animateTo(0);

                              // Copy email and password to sign in fields
                              _emailSignInController.text =
                                  _emailSignUpController.text.trim();
                              _passwordSignInController.text =
                                  _passwordSignUpController.text.trim();

                              // Clear sign up fields
                              _codeSignUpController.clear();
                              _cerevisSignUpController.clear();
                              _emailSignUpController.clear();
                              _passwordSignUpController.clear();
                              _passwordCheckSignUpController.clear();

                              setState(() {
                                _signUpLoading = false;
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Fehler beim Registrieren: $e"),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              );
                              setState(() {
                                _signUpLoading = false;
                              });
                            }
                          },
                          child: Text(
                            "Registrieren",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}