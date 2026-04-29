import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:commercia/data/models/member_model.dart';
import 'package:commercia/data/models/member_viewmodel.dart';
import 'package:commercia/data/repositories/member_repository.dart';
import 'package:commercia/presentation/styles/styles.dart';
import 'package:commercia/presentation/widgets/member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MemberScreen extends StatefulWidget {
  @override
  State<MemberScreen> createState() => _MemberScreenState();
  final ValueNotifier<bool>? isSearchMode;
  const MemberScreen({super.key, this.isSearchMode});
}

class _MemberScreenState extends State<MemberScreen> {
  final MemberViewModel viewModel =
      MemberViewModel(memberRepository: MemberRepository());
  late Future<List<MemberModel>> _members;
  final searchText = ValueNotifier<String>('');
  late final ValueNotifier<bool> _isSearchMode;
  final ScrollController _scrollController = ScrollController();
  int _selectedClubFilter = 0; // 0 = Alle, 1 = Altherren, 2 = Aktivitas
  bool _filterCC = false;
  bool _filterAemtli = false;

  @override
  void initState() {
    super.initState();
    _isSearchMode = widget.isSearchMode ?? ValueNotifier(false);
    _isSearchMode.addListener(() {
      if (!_isSearchMode.value) {
        searchText.value = '';
      }
    });
    _members = getData();
  }

  @override
  void dispose() {
    if (widget.isSearchMode == null) {
      _isSearchMode.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<MemberModel>> getData() async {
    try {
      _members = viewModel.load();
    } catch (Exc) {
      print(Exc);
      setState(() {});
      rethrow;
    }

    setState(() {});
    return _members;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMembers(context, searchText, _isSearchMode),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                _ClubFilterChip(
                  label: 'Alle',
                  selected: _selectedClubFilter == 0,
                  onSelected: (_) => setState(() => _selectedClubFilter = 0),
                ),
                const SizedBox(width: 8),
                _ClubFilterChip(
                  label: 'Altherren',
                  selected: _selectedClubFilter == 1,
                  onSelected: (_) => setState(() => _selectedClubFilter = 1),
                ),
                const SizedBox(width: 8),
                _ClubFilterChip(
                  label: 'Aktive',
                  selected: _selectedClubFilter == 2,
                  onSelected: (_) => setState(() => _selectedClubFilter = 2),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SizedBox(
                    height: 24,
                    child: VerticalDivider(
                      thickness: 1.5,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                _ClubFilterChip(
                  label: 'CC',
                  selected: _filterCC,
                  onSelected: (val) => setState(() => _filterCC = val),
                ),
                const SizedBox(width: 8),
                _ClubFilterChip(
                  label: 'Ämtli',
                  selected: _filterAemtli,
                  onSelected: (val) => setState(() => _filterAemtli = val),
                ),
              ],
            ),
          ),
          // Member List
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: searchText,
              builder: (context, value, child) => FutureBuilder(
                future: _members,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          '${snapshot.error} occurred',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      return Align(
                        alignment: Alignment.topCenter,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            children: snapshot.data!
                                .where((member) =>
                                    member.search.contains(
                                        searchText.value.toLowerCase()) &&
                                    (_selectedClubFilter == 0 ||
                                        member.club == _selectedClubFilter) &&
                                    (_filterCC && _filterAemtli
                                        ? member.role != 0
                                        : _filterCC
                                            ? (member.role >= 1 &&
                                                member.role <= 5)
                                            : _filterAemtli
                                                ? member.role > 5
                                                : true))
                                .map((member) => UserCard(
                                      key: ValueKey(member.id),
                                      member: member,
                                      allMembers: snapshot.data!,
                                    ))
                                .toList(),
                          ),
                        ),
                      );
                    }
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _ClubFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      shape: StadiumBorder(),
      selectedColor: Theme.of(context).colorScheme.primary,
      side: BorderSide(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outlineVariant,
      ),
      labelStyle: TextStyle(
        color: selected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class UserCard extends StatefulWidget {
  final MemberModel member;
  final List<MemberModel> allMembers;

  const UserCard({
    super.key,
    required this.member,
    required this.allMembers,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  @override
  Widget build(BuildContext context) {
    final member = widget.member;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 1,
            color: Theme.of(context).colorScheme.primaryContainer,
            surfaceTintColor: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                context.pushNamed(
                  'member_details',
                  pathParameters: {'id': member.id},
                  extra: widget.allMembers,
                ).then((_) {
                  if (mounted) setState(() {});
                });
              },
              // onTap: () {
              //   Navigator.of(context)
              //       .push(
              //         MaterialPageRoute(
              //           builder: (_) => MemberDetails(
              //             member: member,
              //             allMembers: widget.allMembers,
              //           ),
              //         ),
              //       )
              //       .then((_) {
              //     // Rebuild only this card to pick up any avatar change.
              //     // The model was already mutated in place by MemberDetails,
              //     // so no full list reload is needed.
              //     if (mounted) setState(() {});
              //   });
              //},
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.cerevis, style: TitleTextStyle),
                        Text(member.name, style: BodyTextStyle),
                        const SizedBox(height: 56),
                        Row(
                          children: [
                            if (member.role != 0)
                              Icon(Icons.keyboard_double_arrow_up, size: 24),
                            SizedBox(width: 5),
                            Text(member.role_text),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: MemberAvatar.medium(member: member),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

AppBarWithSearchSwitch appBarMembers(BuildContext context,
    ValueNotifier<String> searchText, ValueNotifier<bool> isSearchMode) {
  return AppBarWithSearchSwitch(
    customIsSearchModeNotifier: isSearchMode,
    customTextNotifier: searchText,
    // onChanged: (text) => searchText.value = text,
    clearOnClose: true,
    fieldHintText: 'Suchen',
    appBarBuilder: (context) {
      return AppBar(
        title: Text('Mitglieder'),
        actions: [
          AppBarSearchButton(),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              context.pushNamed('settings');
            },
          ),
        ],
      );
    },
  );
}