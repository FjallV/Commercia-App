import 'package:commercia/data/models/song_model.dart';
import 'package:commercia/data/repositories/song_repository.dart';
import 'package:flutter/widgets.dart';

class SongViewModel extends ChangeNotifier {
  SongViewModel({
    required SongRepository songRepository,
  }) : _songRepository = songRepository;

  final SongRepository _songRepository;

  List<SongModel> _songs = [];
  List<SongModel> get songs => _songs;

  Future<List<SongModel>> load() async {
    try {
      final songResult = await _songRepository.getSongs();
      // switch (eventResult) {
      //    case Ok<Event>():
      //     _user = userResult.value;
      //     _log.fine('Loaded user');
      //   case Error<Event>():
      //     _log.warning('Failed to load events', eventResult.error);
      // }

      // ...
      _songs = songResult;
      print('Songs geladen');
      return songResult;
    } finally {
      notifyListeners();
    }
  }
}
