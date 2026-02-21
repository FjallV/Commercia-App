import 'package:commercia/data/models/member_model.dart';
import 'package:flutter/material.dart';

/// Reusable round member photo widget.
/// Use [MemberAvatar.medium] for cards, [MemberAvatar.large] for detail/edit pages.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.member,
    this.radius = 40,
  });

  /// 40px radius — for member list cards
  const MemberAvatar.medium({super.key, required this.member}) : radius = 40;

  /// 64px radius — for detail and edit pages
  const MemberAvatar.large({super.key, required this.member}) : radius = 64;

  final MemberModel member;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final photoUrl = member.photo_url;

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primaryContainer,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: photoUrl != null && photoUrl.isNotEmpty
            ? Image.network(
                photoUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(context),
              )
            : _placeholder(context),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Center(
      child: Icon(
        Icons.person,
        size: radius * 1.6,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}