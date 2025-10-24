class MemberModel {

  String id;
  String cerevis;
  String name;
  String? name_first;
  String? name_last;
  int club;
  String club_text;
  int role;
  String role_text;
  int? bfam;
  String? bfam_text;
  String search;
  String? image;

  MemberModel({
    required this.id,
    required this.name,
    required this.cerevis,
    this.name_first, 
    this.name_last,
    required this.club,
    required this.club_text,
    required this.role,
    required this.role_text,
    this.bfam,
    this.bfam_text,
    required this.search,
    this.image,
  });
}
