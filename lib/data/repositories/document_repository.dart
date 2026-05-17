import 'package:commercia/data/models/document_links_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DocumentRepository {
  Future<List<DocumentLinksModel>> getLinks() async {
    List<DocumentLinksModel> documentLinks = [];

    final results = await Supabase.instance.client.from('document_links').select();

    for (var result in results) {

      documentLinks.add(DocumentLinksModel(
        id: result['id'],
        name: result['name'],
        url: result['url'],
        icon: result['icon'],
      ));
    }

    documentLinks.sort((a, b) => a.name.compareTo(b.name));

    return documentLinks;
  }
}
