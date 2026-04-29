import 'dart:convert';
import 'package:commercia/app_state.dart';
import 'package:commercia/data/models/member_model.dart';
import 'package:commercia/data/repositories/member_repository.dart';
import 'package:commercia/presentation/screens/member_edit_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_html/html.dart' as html;
import 'package:commercia/presentation/widgets/member_avatar.dart';
import 'package:url_launcher/url_launcher.dart';

class MemberDetails extends StatefulWidget {
  const MemberDetails({
    super.key,
    required this.member,
    required this.allMembers,
  });
  final MemberModel member;
  final List<MemberModel> allMembers;

  @override
  State<MemberDetails> createState() => _MemberDetailsState();
}

class _MemberDetailsState extends State<MemberDetails> {
  // The currently displayed member — swapped in-place when tapping
  // Bieralter/Bierjunge so the GoRouter stack never grows.
  late MemberModel _current;

  // Incremented after a successful edit to force the avatar to re-render
  // with a fresh network image (busts Flutter's in-memory image cache).
  int _avatarVersion = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _current = widget.member;
  }

  void _navigateTo(MemberModel member) {
    _scrollController.jumpTo(0);
    setState(() {
      _current = member;
      _avatarVersion = 0;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── vCard download (web) ─────────────────────────────────────────────────
  void _downloadVCard() {
    final member = _current;
    final nameParts = member.name.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final lines = [
      'BEGIN:VCARD',
      'VERSION:3.0',
      'N:$lastName;$firstName;;;',
      'FN:${member.name}',
      'NICKNAME:${member.cerevis}',
      if (member.mobile != null && member.mobile!.isNotEmpty)
        'TEL;TYPE=CELL:${member.mobile}',
      if (member.email != null && member.email!.isNotEmpty)
        'EMAIL:${member.email}',
      if (member.birthday != null) 'BDAY:${member.birthday}',
      'ORG:${member.club_text}',
      'TITLE:${member.role_text}',
      'END:VCARD',
    ];

    final vcfContent = lines.join('\r\n');
    final bytes = utf8.encode(vcfContent);
    final blob = html.Blob([bytes], 'text/vcard');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', '${member.cerevis}.vcf')
      ..click();
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Kontaktdatei wurde heruntergeladen. Bitte aus Downloads öffnen.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Native contacts (mobile) ─────────────────────────────────────────────
  Future<void> _addToNativeContacts(BuildContext context) async {
    final member = _current;
    if (!await FlutterContacts.requestPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kontaktzugriff verweigert.')),
      );
      return;
    }

    final nameParts = member.name.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final contact = Contact()
      ..name = Name(first: firstName, last: lastName)
      ..phones = [
        if (member.mobile != null && member.mobile!.isNotEmpty)
          Phone(member.mobile!),
      ]
      ..emails = [
        if (member.email != null && member.email!.isNotEmpty)
          Email(member.email!),
      ]
      ..organizations = [
        Organization(company: member.club_text, title: member.role_text),
      ];

    await FlutterContacts.openExternalInsert(contact);
  }

  void _handleAddToContacts(BuildContext context) {
    if (kIsWeb) {
      _downloadVCard();
    } else {
      _addToNativeContacts(context);
    }
  }

  Future<void> _openEdit() async {
    final scrollOffset = _scrollController.offset;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MemberEditScreen(member: _current),
      ),
    );
    if (!mounted) return;

    // Fetch only the edited member — no need to reload the full list.
    try {
      final refreshed = await MemberRepository().fetchMemberById(_current.id);
      if (!mounted) return;

      // Evict the cached image only if the photo URL actually changed.
      if (refreshed.photo_url != _current.photo_url) {
        final oldUrl = _current.photo_url;
        if (oldUrl != null && oldUrl.isNotEmpty) {
          await NetworkImage(oldUrl).evict();
        }
      }

      // Mutate the shared model in place so the list entry stays in sync.
      _current
        ..photo_url = refreshed.photo_url
        ..email = refreshed.email
        ..mobile = refreshed.mobile
        ..job = refreshed.job
        ..empl = refreshed.empl;
    } catch (_) {
      // Non-fatal: MemberEditScreen already wrote values back optimistically.
    }

    setState(() => _avatarVersion++);

    // Restore scroll position after the rebuild is laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          scrollOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final member = _current;
    final bierjungen =
        widget.allMembers.where((m) => m.balt == member.cerevis).toList();

    return Scaffold(
      appBar: appBarMemberDetails(context),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Edit button — only visible when viewing own profile
            ValueListenableBuilder<MemberModel?>(
              valueListenable: AppState.instance.member,
              builder: (context, loggedIn, _) {
                if (loggedIn == null || loggedIn.id != member.id) {
                  return const SizedBox.shrink();
                }
                return Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Bearbeiten',
                      onPressed: _openEdit, // <-- uses the new helper
                    ),
                  ),
                );
              },
            ),
            if (member.mobile != null && member.mobile!.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.call_outlined),
                tooltip: 'Anrufen',
                onPressed: () =>
                    launchUrl(Uri(scheme: 'tel', path: member.mobile)),
              ),
            if (member.email != null && member.email!.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.mail_outline),
                tooltip: 'E-Mail senden',
                onPressed: () =>
                    launchUrl(Uri(scheme: 'mailto', path: member.email)),
              ),
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              tooltip: 'Kontakt speichern',
              onPressed: () => _handleAddToContacts(context),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 600,
            child: ListView(
              padding: const EdgeInsets.all(10),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Header: cerevis + name left, avatar right
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.cerevis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 24),
                            ),
                            Text(
                              member.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // key forces Flutter to recreate the widget (and re-fetch
                      // the image) whenever _avatarVersion changes after an edit.
                      KeyedSubtree(
                        key: ValueKey(_avatarVersion),
                        child: MemberAvatar.large(member: member),
                      ),
                    ],
                  ),
                ),
                // Club + Role
                ListTile(
                  leading: const Icon(Icons.group_outlined),
                  title: Text(member.club_text),
                  subtitle: member.role_text.isNotEmpty
                      ? Text(member.role_text)
                      : null,
                ),
                // Birthday
                if (member.birthday != null)
                  ListTile(
                    leading: const Icon(Icons.cake_outlined),
                    title: Text(member.birthday_text!),
                    subtitle: Text('${member.age} Jahre alt'),
                  ),
                // Mobile
                if (member.mobile != null && member.mobile!.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: Text(member.mobile!),
                    onTap: () =>
                        launchUrl(Uri(scheme: 'tel', path: member.mobile)),
                  ),
                // Email
                if (member.email != null && member.email!.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.mail_outline),
                    title: Text(member.email!),
                    onTap: () =>
                        launchUrl(Uri(scheme: 'mailto', path: member.email)),
                  ),
                // Job + Employer
                if ((member.job != null && member.job!.isNotEmpty) ||
                    (member.empl != null && member.empl!.isNotEmpty))
                  ListTile(
                    leading: const Icon(Icons.work_outline),
                    title: member.job != null && member.job!.isNotEmpty
                        ? Text(member.job!)
                        : null,
                    subtitle: member.empl != null && member.empl!.isNotEmpty
                        ? Text(member.empl!)
                        : null,
                  ),
                // Bieralter + Bierjunge section
                if (member.balt != null && member.balt!.isNotEmpty ||
                    bierjungen.isNotEmpty) ...[
                  const Divider(),
                  if (member.balt != null && member.balt!.isNotEmpty) ...[
                    _SectionLabel(label: 'Bieralter', context: context),
                    ListTile(
                      title: Text(member.balt!),
                      onTap: () {
                        final balt = widget.allMembers.firstWhere(
                          (m) => m.cerevis == member.balt,
                          orElse: () => member,
                        );
                        if (balt != member) _navigateTo(balt);
                      },
                    ),
                  ],
                  if (bierjungen.isNotEmpty) ...[
                    _SectionLabel(label: 'Bierjunge', context: context),
                    ...bierjungen.map(
                      (bj) => ListTile(
                        title: Text(bj.cerevis),
                        onTap: () => _navigateTo(bj),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _SectionLabel({required String label, required BuildContext context}) {
  return Padding(
    padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
            letterSpacing: 0.8,
          ),
    ),
  );
}

AppBar appBarMemberDetails(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    automaticallyImplyLeading: false,
    actions: [
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => GoRouter.of(context).pop(),
      ),
    ],
  );
}
