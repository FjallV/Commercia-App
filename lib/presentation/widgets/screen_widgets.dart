import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:commercia/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pwa_install/pwa_install.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:commercia/main.dart';

SystemUiOverlayStyle systemOverlayStyle() {
  const Brightness _brightness = Brightness.dark;

  return SystemUiOverlayStyle(
    statusBarColor: Colors.red,
    statusBarIconBrightness: _brightness, // Android
    statusBarBrightness: _brightness, // iOS
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: _brightness,
    systemNavigationBarDividerColor: Colors.transparent,
  );
}

AppBar appBarLogin() {
  return AppBar(
    //systemOverlayStyle: systemOverlayStyle(),
    title: const Text(
      'Login',
      style: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 24), //TODO: FontWeight doesnt apply in web
    ),
    centerTitle: false,
    elevation: 1.0,
    shadowColor: Colors.grey,
    scrolledUnderElevation: 1.0,
    surfaceTintColor: Colors.transparent,
  );
}

AppBar appBarMain(BuildContext context) {
  return AppBar(
      // //systemOverlayStyle: systemOverlayStyle(),
      // title: const Text(
      //   'Commercia App',
      //   style: TextStyle(
      //       color: Colors.red,
      //       fontWeight: FontWeight.w300,
      //       fontSize: 24), //TODO: FontWeight doesnt apply in web
      // ),
      // backgroundColor: Theme.of(context).colorScheme.primary,
      // centerTitle: false,
      // elevation: 1.0,
      // shadowColor: Colors.grey,
      // scrolledUnderElevation: 1.0,
      // surfaceTintColor: Colors.transparent,
      );
}

AppBar appBarEventsOld(BuildContext context) {
  return AppBar(
    //systemOverlayStyle: systemOverlayStyle(),
    title: const Text(
      'Anlässe',
      // style: TextStyle(
      //     color: Colors.red,
      //     fontWeight: FontWeight.w300,
      //     fontSize: 24), //TODO: FontWeight doesnt apply in web
    ),
    //backgroundColor: Colors.white,
/*     centerTitle: false,
    elevation: 1.0,
    shadowColor: Colors.grey,
    scrolledUnderElevation: 1.0,
    surfaceTintColor: Colors.transparent, */
    actions: <Widget>[
      IconButton(
        icon: Icon(
          Icons.search,
          color: Colors.red,
        ),
        onPressed: () {
          // do something
          context.pushNamed('settings');
        },
      ),
      IconButton(
        icon: Icon(
          Icons.settings,
          color: Colors.red,
        ),
        onPressed: () {
          // do something
          context.pushNamed('settings');
        },
      )
    ],
  );
}

AppBar appBarDetails(BuildContext context, String title) {
  return AppBar(
    // systemOverlayStyle: systemOverlayStyle(),
    title: FittedBox(
        fit: BoxFit.fitWidth, 
        child: Text(title)
    ),
    leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => GoRouter.of(context).pop()),
  );
}

Drawer drawer(BuildContext context, CommerciaApp app) {
  return Drawer(
    backgroundColor: Colors.white,
    child: ListView(
      // Important: Remove any padding from the ListView.
      //TODO: Add username/cerevis
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.red),
          child: Text('Drawer Header'),
        ),
        ListTile(
          title: const Text('App installieren'),
          leading: Icon(
            Icons.install_mobile,
            color: Colors.black,
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
        ),
        ListTile(
          title: const Text('Logout'),
          leading: Icon(
            Icons.logout,
            color: Colors.black,
          ),
          onTap: () async {
            // Logout user
            await Supabase.instance.client.auth.signOut();
          },
        ),
        ListTile(
          title: const Text('Dark'),
          leading: Icon(
            Icons.dark_mode,
            color: Colors.black,
          ),
          onTap: () {
            themeNotifier.value = ThemeMode.dark;
          },
        ),
        ListTile(
          title: const Text('Light'),
          leading: Icon(
            Icons.light,
            color: Colors.black,
          ),
          onTap: () {},
        ),
        SwitchListTile(
          title: Text("Dark Mode"),
          value: themeNotifier.value == ThemeMode.dark,
          onChanged: (value) {
            themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
          },
        ),
      ],
    ),
  );
}

class Screen extends StatelessWidget {
  final String content;
  final IconData icon;

  const Screen({Key? key, required this.content, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Colors.red),
          const SizedBox(height: 20),
          Text(
            content,
            style: const TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
