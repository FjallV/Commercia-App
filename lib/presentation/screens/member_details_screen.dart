import 'dart:convert';
import 'package:commercia/app_state.dart';
import 'package:commercia/data/models/member_model.dart';
import 'package:commercia/presentation/screens/member_edit_screen.dart';
import 'package:commercia/presentation/styles/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

class MemberDetails extends StatelessWidget {
  const MemberDetails({
    super.key,
    required this.member,
    required this.allMembers,
  });
  final MemberModel member;
  final List<MemberModel> allMembers;

  // ── vCard download (web) ─────────────────────────────────────────────────
  void _downloadVCard() {
    final nameParts = member.name.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

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
  }

  // ── Native contacts (mobile) ─────────────────────────────────────────────
  Future<void> _addToNativeContacts(BuildContext context) async {
    final member = this.member;
    if (!await FlutterContacts.requestPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kontaktzugriff verweigert.')),
      );
      return;
    }

    final nameParts = member.name.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

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

  @override
  Widget build(BuildContext context) {
    final member = this.member;
    final bierjungen = allMembers
        .where((m) => m.balt == member.cerevis)
        .toList();

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
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MemberEditScreen(member: member),
                        ),
                      ),
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
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 600,
            child: ListView(
              padding: const EdgeInsets.all(10),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Cerevis + full name
                ListTile(
                  title: Text(
                    member.cerevis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 24),
                  ),
                  subtitle: Text(
                    member.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 18),
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
                // Bieralter
                if (member.balt != null && member.balt!.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.sports_bar_outlined),
                    title: const Text('Bieralter'),
                    subtitle: Text(member.balt!),
                  ),
                // Bierjungen
                if (bierjungen.isNotEmpty) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
                    child: Text(
                      'Bierjungen',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.55),
                            letterSpacing: 0.8,
                          ),
                    ),
                  ),
                  ...bierjungen.map(
                    (bj) => ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(bj.cerevis),
                      subtitle: Text(bj.name),
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => MemberDetails(member: bj, allMembers: allMembers),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

AppBar appBarMemberDetails(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(5),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      onPressed: () => GoRouter.of(context).pop(),
    ),
  );
}