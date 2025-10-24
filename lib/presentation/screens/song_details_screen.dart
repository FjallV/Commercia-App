import 'package:commercia/data/models/song_model.dart';
import 'package:commercia/presentation/widgets/screen_widgets.dart';
import 'package:flutter/material.dart';

class SongDetails extends StatelessWidget {
  SongDetails({super.key, required this.song});
  SongModel song;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: appBarDetails(context, song.title),
      body: 
      SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              width: 600,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(song.lyrics, textScaler: TextScaler.linear(1.2),)
                // Container(
                //   width: 600,
                //   child: ListView(
                //         padding: EdgeInsets.all(10),
                //         shrinkWrap: true,
                //         children: [
                //       ListTile(
                //         leading: Icon(Icons.title),
                //         title: Text(song.title),
                //       ),
                //       ListTile(
                //         titleAlignment: ListTileTitleAlignment.top,
                //         leading: Icon(Icons.lyrics),
                //         title: Text(song.lyrics),
                //       ),
                //     ]),
                // ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
