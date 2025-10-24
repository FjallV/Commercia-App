import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:commercia/data/models/member_model.dart';
import 'package:commercia/data/models/member_viewmodel.dart';
import 'package:commercia/data/repositories/member_repository.dart';
import 'package:commercia/presentation/styles/styles.dart';
import 'package:commercia/presentation/widgets/screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class MemberScreen extends StatefulWidget {
  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  final MemberViewModel viewModel =
      MemberViewModel(memberRepository: MemberRepository());
  late Future<List<MemberModel>> _members;
  final searchText = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    _members = getData();
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
      appBar: appBarMembers(context, searchText),
      body: ValueListenableBuilder(
        valueListenable: searchText,
        builder: (context, value, child) => FutureBuilder(
          // Future that needs to be resolved
          // inorder to display something on the Canvas
          future: _members,
          builder: (context, snapshot) {
            // Checking if future is resolved or not
            if (snapshot.connectionState == ConnectionState.done) {
              // If we got an error
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} occurred',
                    style: TextStyle(fontSize: 18),
                  ),
                );

                // if we got our data
              } else if (snapshot.hasData) {
                // Extracting data from snapshot object
                return Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    child: Column(
                      children: snapshot.data!
                          .where((member) => member.search
                              .contains(searchText.value.toLowerCase()))
                          .map((member) => UserCard(member: member))
                          .toList(),
                    ),
                  ),
                );
              }
            }
            // Displaying LoadingSpinner to indicate waiting state
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final MemberModel member;
  const UserCard({required this.member});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // runde Ecken
            ),
            elevation: 1,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.cerevis,
                        style: TitleTextStyle
                      ),
                      Text(
                        member.name,
                        style: BodyTextStyle
                      ),
                      const SizedBox(height: 56),
                      Row(
                        children: [
                          if(member.role != 0)
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
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        size: 64, // icon fits nicely inside the circle
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

AppBarWithSearchSwitch appBarMembers(
    BuildContext context, ValueNotifier<String> searchText) {
  return AppBarWithSearchSwitch(
    onChanged: (text) => searchText.value = text,
    clearOnClose: true,
    fieldHintText: 'Suchen',
    appBarBuilder: (context) {
      return AppBar(
        title: Text('Mitglieder'),
        actions: [
          AppBarSearchButton(),
          IconButton(
            icon: Icon(
              Icons.settings,
            ),
            onPressed: () {
              context.pushNamed('settings');
            },
          ),
        ],
      );
    },
  );
}
