import 'package:commercia/data/models/song_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SongRepository {
  Future<List<SongModel>> getSongs() async {
    List<SongModel> songs = [];

    final results = await Supabase.instance.client.from('songs').select();

    for (var result in results) {

      songs.add(SongModel(
        id: result['id'],
        title: result['title'],
        lyrics: result['lyrics'] ?? '',
        search: result['search'] ?? '',
      ));
    }

    songs.sort((a, b) => a.search.compareTo(b.search));

    return songs;
  }
}
