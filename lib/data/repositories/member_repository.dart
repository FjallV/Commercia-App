import 'package:commercia/business/images.dart';
import 'package:commercia/data/models/member_model.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberRepository {
  /// Maps a raw Supabase row to a [MemberModel], including all derived fields.
  static MemberModel fromRow(Map<String, dynamic> result) {
    // Club
    String club_text = switch (result['club']) {
      1 => 'Altherr',
      2 => 'Aktiver',
      _ => '',
    };

    // Role
    String role_text = switch (result['role']) {
      1 => 'Präsident',
      2 => 'Quästor',
      3 => 'Aktuar',
      4 => 'Beisitzer',
      5 => 'Fuxmajor',
      6 => 'Sportmagister',
      7 => 'Cantusmagister',
      8 => 'Revisor',
      _ => '',
    };

    // Bierfamilie
    String bfam_text = switch (result['bfam']) {
      1 => 'Vita',
      2 => 'Slow',
      3 => '',
      _ => '',
    };

    // Birthday text
    final birthDate = new DateFormat('d. MMMM y', 'de_CH');
    DateTime? date;
    String? birthday_text;
    if( result['birthday'] != null) date = DateTime.parse(result['birthday']);
    if (date != null) {
      birthday_text = birthDate.format(DateTime.parse(
            DateFormat('yyyy-MM-dd').format(date) + "T00:00:00"));
            debugPrint('birthday_text: $birthday_text');
    }

    String age = '';
    if (date != null) {
      DateTime birthDate = date;
      DateTime today = DateTime.now();
      int calculatedAge = today.year - date.year;
      if (today.month < date.month ||
          (today.month == date.month && today.day < date.day)) {
        calculatedAge--;
      }
      age = calculatedAge.toString();
      debugPrint('age: $age');
    }

    final String cerevis = result['cerevis'] ?? '';
    final String name_first = result['name_first'] ?? '';
    final String name_last = result['name_last'] ?? '';

    final String search =
        '$cerevis $name_first $name_last $club_text $role_text'.toLowerCase();

    return MemberModel(
      id: result['id'],
      user_id: result['user_id'],
      name: '$name_first $name_last',
      cerevis: cerevis,
      name_first: name_first,
      name_last: name_last,
      birthday: date,
      birthday_text: birthday_text,
      age: age.isNotEmpty ? int.tryParse(age) : null,
      mobile: result['mobile'],
      email: result['email'],
      club: result['club'],
      club_text: club_text,
      role: result['role'],
      role_text: role_text,
      balt: result['balt'],
      bfam: result['bfam'],
      bfam_text: bfam_text,
      search: search,
      photo_url: result['photo_url'],
    );
  }

  Future<List<MemberModel>> getMembers() async {
    final results = await Supabase.instance.client.from('members').select();
    final members = results.map((r) => fromRow(r)).toList();
    members.sort((a, b) => a.cerevis.compareTo(b.cerevis));
    return members;
  }

  Future<MemberModel?> getMemberById(String id) async {
    final result = await Supabase.instance.client
        .from('members')
        .select()
        .eq('user_id', id)
        .single();
    return fromRow(result);
  }

    /// Uploads a photo to Supabase Storage and updates the member's photo_url.
  /// Returns the public URL of the uploaded photo.
  Future<String> uploadPhoto({
    required String memberId,
    required String cerevis,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final ext = mimeType.contains('png') ? 'png' : 'jpg';
    final path = '$cerevis/photo.$ext';

    await Supabase.instance.client.storage
        .from('member-photos')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );

    // Generate a signed URL (1 year expiry) since bucket is private
    final signedUrl = await Supabase.instance.client.storage
        .from('member-photos')
        .createSignedUrl(path, 60 * 60 * 24 * 365);

    await Supabase.instance.client
        .from('members')
        .update({'photo_url': signedUrl})
        .eq('id', memberId);

    return signedUrl;
  }

  /// Updates the editable contact fields (email, mobile) for a member.
  /// Returns the updated [MemberModel] on success.
  Future<MemberModel> updateContactInfo({
    required String id,
    required String? email,
    required String? mobile,
  }) async {
    final result = await Supabase.instance.client
        .from('members')
        .update({
          'email': email,
          'mobile': mobile,
        })
        .eq('id', id)
        .select()
        .single();
    return fromRow(result);
  }
}