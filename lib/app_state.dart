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

  /// Bei In-place-Mutation des Models (z.B. nach einem Edit) müssen wir
  /// den Notifier explizit anstossen — eine reine Mutation feuert nicht.
  /// Wir setzen kurz auf null und zurück, damit ValueNotifier eine Änderung
  /// erkennt (gleiche Referenz wäre sonst ein No-op).
  void notifyMemberChanged() {
    final current = member.value;
    member.value = null;
    member.value = current;
  }

  void clear() => member.value = null;
}