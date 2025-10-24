import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:commercia/main.dart';
import 'package:commercia/presentation/screens/document_screen.dart';
import 'package:commercia/presentation/screens/event_screen.dart';
import 'package:commercia/presentation/screens/member_screen.dart';
import 'package:commercia/presentation/screens/song_screen.dart';
import 'package:commercia/presentation/widgets/screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_symbols_icons/symbols.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [];

  @override
  void initState() {
    initializeDateFormatting('de_CH');

    _screens.add(EventScreen());
    _screens.add(MemberScreen());
    _screens.add(SongScreen());
    _screens.add(DocumentScreen());
    super.initState();
  }

  void _onItemTapped(int index) {
    // TODO: Disable search mode when switching tabs
    // This is a workaround to disable search mode when switching tabs.
    AppBarWithSearchFinder.of(context)?.isSearchMode.value =
        false; // Disable search mode when switching tabs

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
        onBackButtonPressed: () async {
          // Use the app navigator to navigate to the desired page.
          // GoRouter.of(context).go('/');

          final shouldPop = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('App schliessen?'),
                  //content: Text('Are you sure you want to leave the app?'),
                  actions: [
                    TextButton(
                      child: Text('Abbrechen'),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    TextButton(
                      child: Text('Bestätigen'),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                );
              });
          return shouldPop ?? false;
        },
        child: Scaffold(
            // backgroundColor: Colors.white,
            //appBar: appBarMain(),
            //drawer: drawer(context, app),
            body: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onItemTapped,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today),
                  label: 'Anlässe',
                ),
                NavigationDestination(
                  icon: Icon(Icons.group_outlined),
                  selectedIcon: Icon(Icons.group),
                  label: 'Mitglieder',
                ),
                NavigationDestination(
                  icon: Icon(
                    Symbols.book_2,
                    fill: 0,
                    opticalSize: 48,
                  ),
                  selectedIcon: Icon(
                    Symbols.book_2,
                    fill: 1,
                    opticalSize: 48,
                  ),
                  label: 'Kantprügel',
                ),
                NavigationDestination(
                  icon: Icon(Icons.description_outlined),
                  selectedIcon: Icon(Icons.description),
                  label: 'Dokumente',
                ),
              ],
            )));
  }
}
