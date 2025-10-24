import 'package:commercia/data/models/member_model.dart';
import 'package:commercia/data/repositories/member_repository.dart';
import 'package:flutter/widgets.dart';

class MemberViewModel extends ChangeNotifier {
  MemberViewModel({
    required MemberRepository memberRepository,
  }) : _memberRepository = memberRepository;

  final MemberRepository _memberRepository;

  List<MemberModel> _members = [];
  List<MemberModel> get members => _members;

  Future<List<MemberModel>> load() async {
    try {
      final memberResult = await _memberRepository.getMembers();
      // switch (memberResult) {
      //    case Ok<Member>():
      //     _user = userResult.value;
      //     _log.fine('Loaded user');
      //   case Error<Member>():
      //     _log.warning('Failed to load members', memberResult.error);
      // }

      // ...
      _members = memberResult;
      print('Members geladen');
      return memberResult;
    } finally {
      notifyListeners();
    }
  }
}
