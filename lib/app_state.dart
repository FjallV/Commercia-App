import 'package:flutter/foundation.dart';
import 'package:commercia/data/models/member_model.dart';

/// Global application state.
/// Access the current member from anywhere:
///   AppState.instance.member.value
class AppState {
  AppState._();
  static final AppState instance = AppState._();

  /// The currently authenticated member. null when logged out.
  final ValueNotifier<MemberModel?> member = ValueNotifier(null);

  void setMember(MemberModel? m) => member.value = m;

  void clear() => member.value = null;
}