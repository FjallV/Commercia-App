import 'package:commercia/data/models/document_links_model.dart';
import 'package:commercia/data/repositories/document_repository.dart';
import 'package:flutter/widgets.dart';

class DocumentLinksViewmodel extends ChangeNotifier {
  DocumentLinksViewmodel({
    required DocumentRepository documentLinksRepository,
  }) : _documentRepository = documentLinksRepository;

  final DocumentRepository _documentRepository;

  List<DocumentLinksModel> _documentLinks = [];
  List<DocumentLinksModel> get documentLinks => _documentLinks;

  Future<List<DocumentLinksModel>> load() async {
    try {
      final documentLinksResult = await _documentRepository.getLinks();
      // switch (documentLinksResult) {
      //    case Ok<DocumentLinks>():
      //     _user = userResult.value;
      //     _log.fine('Loaded user');
      //   case Error<DocumentLinks>():
      //     _log.warning('Failed to load document links', documentLinksResult.error);
      // }

      // ...
      _documentLinks = documentLinksResult;
      print('Links geladen');
      return documentLinksResult;
    } finally {
      notifyListeners();
    }
  }
}
