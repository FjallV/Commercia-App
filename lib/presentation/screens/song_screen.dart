import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:commercia/data/models/song_model.dart';
import 'package:commercia/data/models/song_viewmodel.dart';
import 'package:commercia/data/repositories/song_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SongScreen extends StatefulWidget {
  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  final SongViewModel viewModel =
      SongViewModel(songRepository: SongRepository());
  late Future<List<SongModel>> _songs;
  final searchText = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    _songs = getData();
  }

  Future<List<SongModel>> getData() async {
    try {
      _songs = viewModel.load();
    } catch (Exc) {
      print(Exc);
      setState(() {});
      rethrow;
    }

    setState(() {});
    return _songs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarSongs(context, searchText),
      body: ValueListenableBuilder(
        valueListenable: searchText,
        builder: (context, value, child) => FutureBuilder(
          // Future that needs to be resolved
          // inorder to display something on the Canvas
          future: _songs,
          builder: (context, snapshot) {
            // Checking if future is resolved or not
            if (snapshot.connectionState == ConnectionState.done) {
              // If we got an error
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} occurred',
                    style: TextStyle(fontSize: 18),
                  ),
                );

                // if we got our data
              } else if (snapshot.hasData) {
                // Extracting data from snapshot object
                return Center(
                  // child: SingleChildScrollView(
                  child: ListView(
                    //physics: NeverScrollableScrollPhysics(),
                    children: snapshot.data!
                        .where((song) => song.search
                            .toLowerCase()
                            .contains(searchText.value.toLowerCase()))
                        .map((song) => SongItem(song: song))
                        .toList(),
                  ),
                  // ),
                );
              }
            }
            // Displaying LoadingSpinner to indicate waiting state
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
      ),
    );
  }
}

class SongItem extends StatelessWidget {
  final SongModel song;
  const SongItem({required this.song});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 600,
        child: ListTile(
            title: Text(song.title),
            onTap: () {
              context.pushNamed('song_details', extra: song);
            }),
      ),
    );
  }
}

AppBarWithSearchSwitch appBarSongs(
    BuildContext context, ValueNotifier<String> searchText) {
  return AppBarWithSearchSwitch(
    onChanged: (text) => searchText.value = text,
    clearOnClose: true,
    fieldHintText: 'Suchen',
    appBarBuilder: (context) {
      return AppBar(
        title: Text('Kantprügel'),
        actions: [
          AppBarSearchButton(),
          IconButton(
            icon: Icon(
              Icons.settings,
            ),
            onPressed: () {
              context.pushNamed('settings');
            },
          ),
        ],
      );
    },
  );
}
