class DocumentLinksModel {
  String id;
  String name;
  String url;
  String? icon;

  DocumentLinksModel({
    required this.id,
    required this.name,
    required this.url,
    this.icon,
  });
}
