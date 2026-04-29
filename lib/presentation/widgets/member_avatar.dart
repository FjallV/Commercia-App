import 'package:cached_network_image/cached_network_image.dart';
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

  /// 60px radius — for detail and edit pages
  const MemberAvatar.large({super.key, required this.member}) : radius = 60;

  final MemberModel member;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final photoUrl = member.photo_url;

    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: photoUrl != null && photoUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: photoUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                placeholder: (context, url) => _placeholder(context),
                errorWidget: (context, url, error) => _placeholder(context),
              )
            : _placeholder(context),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Center(
        child: Icon(
          Icons.person,
          size: radius * 1.2,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}