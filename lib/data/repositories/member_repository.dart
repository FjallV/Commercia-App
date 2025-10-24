import 'package:commercia/business/images.dart';
import 'package:commercia/data/models/member_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberRepository {
  Future<List<MemberModel>> getMembers() async {
    List<MemberModel> members = [];

    final results = await Supabase.instance.client.from('members').select();

    for (var result in results) {
      // Club
      String club_text = '';
      if (result['club'] == 1) {
        club_text = 'Altherr';
      } else if (result['club'] == 2) {
        club_text = 'Aktiver';
      } else {
        club_text = '';
      }

      // Role
      String role_text = '';
      switch (result['role']) {
        case 1:
          role_text = 'Präsident';
          break;
        case 2:
          role_text = 'Quästor';
          break;
        case 3:
          role_text = 'Aktuar';
          break;
        case 4:
          role_text = 'Fuxmajor';
          break;
        case 5:
          role_text = 'Sportmagister';
          break;
        case 6:
          role_text = 'Cantusmagister';
          break;
        case 7:
          role_text = 'Beisitzer';
          break;
        case 8:
          role_text = 'Revisor';
          break;
        default:
          role_text = '';
      }

      String cerevis = result['cerevis'] ?? '';
      if (cerevis == null || cerevis == '') {
        cerevis = '';
      }

      String image = cerevis.toLowerCase() + '_tn';
      String name_first = result['name_first'] ?? '';
      String name_last = result['name_last'] ?? '';

      String search = cerevis +
          ' ' +
          name_first +
          ' ' +
          name_last +
          ' ' +
          club_text +
          ' ' +
          role_text;
      search = search.toLowerCase();

      members.add(MemberModel(
        id: result['id'],
        name: name_first + ' ' + name_last,
        cerevis: cerevis,
        name_first: name_first,
        name_last: name_last,
        club: result['club'],
        club_text: club_text,
        role: result['role'],
        role_text: role_text,
        search: search,
        image: ImageUtils.getImageLocal(cerevis, 'member'), //Local
      ));
    }

    members.sort((a, b) => a.cerevis.compareTo(b.cerevis));

    return members;
  }
}
