import 'package:commercia/app_state.dart';
import 'package:commercia/data/models/member_viewmodel.dart';
import 'package:commercia/data/repositories/member_repository.dart';
import 'package:commercia/presentation/widgets/member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Zeigt das Avatar des eingeloggten Users in der AppBar.
/// Bei Tap wird zur member_details-Route des eigenen Profils navigiert.
class AppBarUserAvatar extends StatelessWidget {
  const AppBarUserAvatar({super.key});

  Future<void> _onTap(BuildContext context) async {
    final me = AppState.instance.member.value;
    if (me == null) return;

    final allMembers =
        await MemberViewModel(memberRepository: MemberRepository()).load();

    if (!context.mounted) return;
    context.pushNamed(
      'member_details',
      pathParameters: {'id': me.id},
      extra: {
        'allMembers': allMembers,
        'readOnlyRelations': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppState.instance.member,
      builder: (context, member, _) {
        if (member == null) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _onTap(context),
            child: Center(
              child: MemberAvatar.small(member: member),
            ),
          ),
        );
      },
    );
  }
}