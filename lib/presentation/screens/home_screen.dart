import 'package:commercia/presentation/screens/document_screen.dart';
import 'package:commercia/presentation/screens/event_screen.dart';
import 'package:commercia/presentation/screens/member_screen.dart';
import 'package:commercia/presentation/screens/song_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  double _iconSize = 36; //48
  final List<Widget> _screens = [];

  final List<ValueNotifier<bool>> _searchModes = [
    ValueNotifier(false),
    ValueNotifier(false),
    ValueNotifier(false),
    ValueNotifier(false),
  ];

  @override
  void initState() {
    initializeDateFormatting('de_CH');

    _screens.add(EventScreen(isSearchMode: _searchModes[0]));
    _screens.add(MemberScreen(isSearchMode: _searchModes[1]));
    _screens.add(SongScreen(isSearchMode: _searchModes[2]));
    _screens.add(DocumentScreen());
    super.initState();
  }

  void _onItemTapped(int index) {
    // Disable search mode when switching tabs
    _searchModes[_currentIndex].value = false; // close search on current tab

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
            body: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onItemTapped,
              destinations: [
                NavigationDestination(
                  icon: Image.asset(
                    'assets/icons/navigationbar/event.png',
                    width: _iconSize,
                    height: _iconSize,
                    //color: Theme.of(context).colorScheme.primary,
                    color: Theme.of(context)
                        .navigationBarTheme
                        .iconTheme
                        ?.resolve({})?.color,
                  ),
                  selectedIcon: Image.asset(
                    'assets/icons/navigationbar/event_selected.png',
                    width: _iconSize,
                    height: _iconSize,
                    //color: Theme.of(context).colorScheme.primary,
                    color: Theme.of(context)
                        .navigationBarTheme
                        .iconTheme
                        ?.resolve({})?.color,
                  ),
                  label: 'Anlässe',
                ),
                NavigationDestination(
                  icon: Image.asset(
                    'assets/icons/navigationbar/member.png',
                    width: _iconSize,
                    height: _iconSize,
                    //color: Theme.of(context).colorScheme.primary,
                    color: Theme.of(context)
                        .navigationBarTheme
                        .iconTheme
                        ?.resolve({})?.color,
                  ),
                  selectedIcon: Image.asset(
                    'assets/icons/navigationbar/member_selected.png',
                    width: _iconSize,
                    height: _iconSize,
                    //color: Theme.of(context).colorScheme.primary,
                    color: Theme.of(context)
                        .navigationBarTheme
                        .iconTheme
                        ?.resolve({})?.color,
                  ),
                  label: 'Mitglieder',
                ),
                NavigationDestination(
                  icon: Image.asset(
                    'assets/icons/navigationbar/song.png',
                    width: _iconSize,
                    height: _iconSize,
                    //color: Theme.of(context).colorScheme.primary,
                    color: Theme.of(context)
                        .navigationBarTheme
                        .iconTheme
                        ?.resolve({})?.color,
                  ),
                  selectedIcon: Image.asset(
                    'assets/icons/navigationbar/song_selected.png',
                    width: _iconSize,
                    height: _iconSize,
                    //color: Theme.of(context).colorScheme.primary,
                    color: Theme.of(context)
                        .navigationBarTheme
                        .iconTheme
                        ?.resolve({})?.color,
                  ),
                  label: 'Kantprügel',
                ),
                NavigationDestination(
                  icon: Image.asset(
                    'assets/icons/navigationbar/document.png',
                    width: _iconSize,
                    height: _iconSize,
                    //color: Theme.of(context).colorScheme.primary,
                    color: Theme.of(context)
                        .navigationBarTheme
                        .iconTheme
                        ?.resolve({})?.color,
                  ),
                  selectedIcon: Image.asset(
                    'assets/icons/navigationbar/document_selected.png',
                    width: _iconSize,
                    height: _iconSize,
                    //color: Theme.of(context).colorScheme.primary,
                    color: Theme.of(context)
                        .navigationBarTheme
                        .iconTheme
                        ?.resolve({})?.color,
                  ),
                  label: 'Dokumente',
                ),
              ],
            )));
  }
}
