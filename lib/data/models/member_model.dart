class MemberModel {

  String id;
  String? user_id;
  String cerevis;
  String name;
  String? name_first;
  String? name_last;
  DateTime? birthday;
  String? birthday_text;
  int? age;
  String? mobile;
  String? email;
  String? job;
  String? empl;
  int club;
  String club_text;
  int role;
  String role_text;
  String? balt;
  int? bfam;
  String? bfam_text;
  String search;
  String? photo_url;

  MemberModel({
    required this.id,
    this.user_id,
    required this.name,
    required this.cerevis,
    this.name_first, 
    this.name_last,
    this.birthday,
    this.birthday_text,
    this.age,
    this.mobile,
    this.email,
    this.job,
    this.empl,
    required this.club,
    required this.club_text,
    required this.role,
    required this.role_text,
    this.balt,
    this.bfam,
    this.bfam_text,
    required this.search,
    this.photo_url,
  });

  // factory MemberModel.fromMap(Map<String, dynamic> map) {
  //   return MemberModel(
  //     id: map['id'] as String,
  //     cerevis: map['cerevis'] as String,
  //     name: map['name'] as String,
  //     name_first: map['name_first'] as String?,
  //     name_last: map['name_last'] as String?,
  //     club: map['club'] as int,
  //     club_text: map['club_text'] as String,
  //     role: map['role'] as int,
  //     role_text: map['role_text'] as String,
  //     bfam: map['bfam'] as int?,
  //     bfam_text: map['bfam_text'] as String?,
  //     search: map['search'] as String,
  //     image: map['image'] as String?,
  //   );
  // }

}
