class SongModel {
  String id;
  String title;
  String lyrics;
  String search;
  String? type;
  String? info;

  SongModel({
    required this.id,
    required this.title,
    required this.lyrics,
    required this.search,
    this.type,
    this.info,
  });
}
// class SongModel {
//   final String id;
//   final String title;
//   final String lyrics;
//   final MelodyData? melody;
  
//   // Add any other fields you have in your song model
//   final DateTime? createdAt;
//   final DateTime? updatedAt;

//   SongModel({
//     required this.id,
//     required this.title,
//     required this.lyrics,
//     this.melody,
//     this.createdAt,
//     this.updatedAt,
//   });

//   factory SongModel.fromJson(Map<String, dynamic> json) {
//     return SongModel(
//       id: json['id'] as String,
//       title: json['title'] as String,
//       lyrics: json['lyrics'] as String,
//       melody: null, // Will be loaded separately
//       createdAt: json['created_at'] != null 
//         ? DateTime.parse(json['created_at'] as String) 
//         : null,
//       updatedAt: json['updated_at'] != null 
//         ? DateTime.parse(json['updated_at'] as String) 
//         : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'lyrics': lyrics,
//       'created_at': createdAt?.toIso8601String(),
//       'updated_at': updatedAt?.toIso8601String(),
//     };
//   }

//   // Create a copy with updated melody
//   SongModel copyWith({
//     String? id,
//     String? title,
//     String? lyrics,
//     MelodyData? melody,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return SongModel(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       lyrics: lyrics ?? this.lyrics,
//       melody: melody ?? this.melody,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
// }

// // song_repository.dart
// // Repository for managing songs with melodies

// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'supabase_melody_service.dart';

// class SongRepository {
//   final SupabaseClient _supabase = Supabase.instance.client;
//   final SupabaseMelodyService _melodyService = SupabaseMelodyService();

//   // Get song with melody
//   Future<SongModel?> getSongWithMelody(String songId) async {
//     try {
//       // Get song data
//       final songResponse = await _supabase
//           .from('songs')
//           .select('*')
//           .eq('id', songId)
//           .maybeSingle();

//       if (songResponse == null) {
//         return null;
//       }

//       final song = SongModel.fromJson(songResponse);

//       // Get melody for this song
//       final melody = await _melodyService.getMelodyBySongId(songId);

//       return song.copyWith(melody: melody);
//     } catch (e) {
//       throw Exception('Failed to get song with melody: $e');
//     }
//   }

//   // Get all songs with their melodies
//   Future<List<SongModel>> getAllSongsWithMelodies() async {
//     try {
//       final songsResponse = await _supabase.from('songs').select('*');

//       final songs = <SongModel>[];
//       for (var songJson in songsResponse as List) {
//         final song = SongModel.fromJson(songJson);
//         final melody = await _melodyService.getMelodyBySongId(song.id);
//         songs.add(song.copyWith(melody: melody));
//       }

//       return songs;
//     } catch (e) {
//       throw Exception('Failed to get songs with melodies: $e');
//     }
//   }

//   // Create song with melody
//   Future<String> createSongWithMelody(
//     SongModel song,
//     MelodyData melody,
//   ) async {
//     try {
//       // Create song first
//       final songResponse = await _supabase
//           .from('songs')
//           .insert(song.toJson())
//           .select('id')
//           .single();

//       final songId = songResponse['id'] as String;

//       // Create melody linked to the song
//       final melodyWithSongId = MelodyData(
//         songId: songId,
//         title: melody.title,
//         timeSignature: melody.timeSignature,
//         key: melody.key,
//         tempoBpm: melody.tempoBpm,
//         notes: melody.notes,
//       );

//       await _melodyService.createMelody(melodyWithSongId);

//       return songId;
//     } catch (e) {
//       throw Exception('Failed to create song with melody: $e');
//     }
//   }

//   // Update song melody
//   Future<void> updateSongMelody(String songId, MelodyData melody) async {
//     try {
//       // Check if melody exists for this song
//       final existingMelody = await _melodyService.getMelodyBySongId(songId);

//       if (existingMelody != null) {
//         // Update existing melody
//         await _melodyService.updateMelody(existingMelody.id!, melody);
//         await _melodyService.replaceMelodyNotes(
//           existingMelody.id!,
//           melody.notes,
//         );
//       } else {
//         // Create new melody
//         final melodyWithSongId = MelodyData(
//           songId: songId,
//           title: melody.title,
//           timeSignature: melody.timeSignature,
//           key: melody.key,
//           tempoBpm: melody.tempoBpm,
//           notes: melody.notes,
//         );
//         await _melodyService.createMelody(melodyWithSongId);
//       }
//     } catch (e) {
//       throw Exception('Failed to update song melody: $e');
//     }
//   }

//   // Delete song and its melody
//   Future<void> deleteSong(String songId) async {
//     try {
//       // Delete song (melody will be cascade deleted)
//       await _supabase.from('songs').delete().eq('id', songId);
//     } catch (e) {
//       throw Exception('Failed to delete song: $e');
//     }
//   }
// }