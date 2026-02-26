class EventModel {
  String id;
  String title;
  String? subtitle;
  DateTime? date;
  DateTime? date_start;
  DateTime? date_end;
  DateTime? start_dt;
  DateTime? end_dt;
  String? date_long;
  String? date_short;
  String? time_meet;
  String? time_start;
  String? time_end;
  String? time_text;
  String? location;
  String? location_meet;
  String? location_details;
  String? cost_show;
  String? cost;
  String? cost_ak;
  String? cost_text;
  String? link;
  String? tenue;
  String? tenue_text;
  String? type;
  String? type_text;
  String? info;
  String? image;
  String? signup_url;
  String? details;
  String? card_text;
  int?  club;
  bool? details_tbd;

  EventModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.image,
    this.date,
    this.date_start,
    this.date_end,
    this.date_long,
    this.date_short,
    this.start_dt,
    this.end_dt,
    this.time_meet,
    this.time_start,
    this.time_end,
    this.time_text,
    this.signup_url,
    this.card_text,
    this.location,
    this.location_meet,
    this.location_details,
    this.cost_show,
    this.cost,
    this.cost_ak,
    this.cost_text,
    this.tenue_text,
    this.club,
    this.details,
    this.details_tbd,
  });
}
