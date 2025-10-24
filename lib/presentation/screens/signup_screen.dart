import 'package:commercia/presentation/widgets/screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _signInLoading = false;
  bool _signUpLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: appBarLogin(),
    //   //backgroundColor: Colors.white,
    //   body: DefaultTabController(length: 2, child: SignIn()),
    // );

    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.directions_car)),
                Tab(icon: Icon(Icons.directions_transit)),
              ],
            ),
            title: const Text('Tabs Demo'),
          ),
          body: TabBarView(
            children: [
              SignIn(),
              Icon(Icons.directions_transit),
            ],
          ),
        ),
      ),
    );
  }

  Widget SignIn() {
    return Center(
      child: Container(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(
                20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Commercia logo
                  Container(
                    width: 100,
                    height: 100,
                    child: Material(
                      // with Material
                      child: Image(
                        image: AssetImage('assets/icons/icon_launcher.png'),
                        // height: 200,
                        // width: 200,
                      ),
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                    ),
                  ),
                  SizedBox(height: 100),
                  //Email field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Field is required';
                      }
                      return null;
                    },
                    controller: _emailController,
                    decoration: const InputDecoration(label: Text("Email")),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  //Password field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Field is required';
                      }
                      return null;
                    },
                    controller: _passwordController,
                    decoration: const InputDecoration(label: Text("Passwort")),
                    obscureText: true,
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
                            final isValid = _formKey.currentState?.validate();
                            if (isValid != true) {
                              return;
                            }
                            setState(() {
                              _signInLoading = true;
                            });
                            try {
                              await supabase.auth.signInWithPassword(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim());
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Fehler beim Login"),
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
                            "Login",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                  const Divider(),
                  //SignUp Button
                  OutlinedButton(
                    onPressed: () {
                      context.pushNamed('signup');
                    },
                    child: Text(
                      "Sign Up",
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
