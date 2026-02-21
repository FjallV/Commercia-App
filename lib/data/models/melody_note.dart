// melody_note.dart
// Model for storing individual notes

class MelodyNote {
  final String note; // e.g., "C5", "D5", "REST"
  final int midiNote; // MIDI note number (60 = Middle C, 0 = rest)
  final int durationMs; // Duration in milliseconds
  final String? lyric; // Optional lyric for this note

  MelodyNote({
    required this.note,
    required this.midiNote,
    required this.durationMs,
    this.lyric,
  });

  factory MelodyNote.fromJson(Map<String, dynamic> json) {
    return MelodyNote(
      note: json['note'] as String,
      midiNote: json['midi'] as int,
      durationMs: json['duration'] as int,
      lyric: json['lyric'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'note': note,
      'midi': midiNote,
      'duration': durationMs,
      'lyric': lyric,
    };
  }

  bool get isRest => midiNote == 0 || note == 'REST';
}

// melody_data.dart
// Full melody with metadata

class MelodyData {
  final String title;
  final String timeSignature;
  final String key;
  final int tempoBpm;
  final List<MelodyNote> notes;

  MelodyData({
    required this.title,
    required this.timeSignature,
    required this.key,
    required this.tempoBpm,
    required this.notes,
  });

  factory MelodyData.fromJson(Map<String, dynamic> json) {
    return MelodyData(
      title: json['song_title'] as String,
      timeSignature: json['time_signature'] as String,
      key: json['key'] as String,
      tempoBpm: json['tempo_bpm'] as int,
      notes: (json['melody'] as List)
          .map((noteJson) => MelodyNote.fromJson(noteJson))
          .toList(),
    );
  }
}

// melody_player.dart
// Service to play melodies using flutter_midi

// import 'package:flutter_midi/flutter_midi.dart';
// import 'package:flutter/services.dart';

// class MelodyPlayer {
//   final FlutterMidi _flutterMidi = FlutterMidi();
//   bool _isInitialized = false;
//   bool _isPlaying = false;

//   Future<void> initialize() async {
//     if (_isInitialized) return;
    
//     // Load a soundfont (you'll need to add this to assets)
//     String soundfont = 'assets/soundfonts/piano.sf2';
//     ByteData byte = await rootBundle.load(soundfont);
//     _flutterMidi.prepare(sf2: byte, name: soundfont.split('/').last);
    
//     _isInitialized = true;
//   }

//   Future<void> playMelody(MelodyData melody, {Function? onComplete}) async {
//     if (!_isInitialized) {
//       await initialize();
//     }

//     if (_isPlaying) {
//       stopMelody();
//     }

//     _isPlaying = true;

//     for (var note in melody.notes) {
//       if (!_isPlaying) break; // Allow stopping mid-playback

//       if (!note.isRest) {
//         _flutterMidi.playMidiNote(midi: note.midiNote);
//       }

//       // Wait for the note duration
//       await Future.delayed(Duration(milliseconds: note.durationMs));

//       if (!note.isRest) {
//         _flutterMidi.stopMidiNote(midi: note.midiNote);
//       }
//     }

//     _isPlaying = false;
//     if (onComplete != null) {
//       onComplete();
//     }
//   }

//   void stopMelody() {
//     _isPlaying = false;
//     // Stop all notes
//     for (int i = 0; i < 128; i++) {
//       _flutterMidi.stopMidiNote(midi: i);
//     }
//   }

//   bool get isPlaying => _isPlaying;

//   void dispose() {
//     stopMelody();
//   }
// }