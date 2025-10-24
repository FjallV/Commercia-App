import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:commercia/data/models/event_model.dart';
import 'package:commercia/data/models/event_viewmodel.dart';
import 'package:commercia/data/repositories/event_repository.dart';
import 'package:commercia/presentation/styles/styles.dart';
import 'package:commercia/presentation/widgets/screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class EventScreen extends StatefulWidget {
  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final EventViewModel viewModel =
      EventViewModel(eventRepository: EventRepository());
  late Future<List<EventModel>> _events;
  final searchText = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    _events = getData();
  }

  Future<List<EventModel>> getData() async {
    try {
      _events = viewModel.load();
    } catch (Exc) {
      print(Exc);
      setState(() {});
      rethrow;
    }

    setState(() {});
    return _events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarEvents(context, searchText),
      body: ValueListenableBuilder(
        valueListenable: searchText,
        builder: (context, value, child) => FutureBuilder(
          // Future that needs to be resolved
          // inorder to display something on the Canvas
          future: _events,
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
                          .where((event) => event.title
                              .toLowerCase()
                              .contains(searchText.value.toLowerCase()))
                          .map((event) => EventCard(event: event))
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

class EventCard extends StatelessWidget {
  final EventModel event;
  const EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            color: Theme.of(context).colorScheme.primaryContainer,
            surfaceTintColor: Colors.transparent, // Not applied
            clipBehavior: Clip.hardEdge,
            elevation: 1,
            child: InkWell(
              onTap: () {
                context.pushNamed('event_details', extra: event);
              },
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      //width: 400,
                      height: 200,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Hero(
                            tag: event.id,
                            child: Image(
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              //image: NetworkImage(item.image!),
                              image: AssetImage(event.image!),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: 25,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: Text(
                                      event.date_short!,
                                      style: ChipTextStyle
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: TitleTextStyle  
                          ),
                          SizedBox(height: 3),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  event.card_text!,
                                  style: BodyTextStyle
                                ),
                              // Transform.translate(
                              //   offset: Offset(0, 4),
                              //   child: ImageIcon(
                              //     AssetImage("assets/icons/event_meet2.png"),
                              //     size: 14,
                              //   ),
                              //   // Icon(
                              //   //   Icons.schedule,
                              //   //   color: Colors.grey,
                              //   //   size: 14,
                              //   //   weight: 500.0,
                              //   // )
                              // ),
                              //Padding(
                                //padding: const EdgeInsets.only(left: 5),
                                // child: Text(
                                //   event.card_text!,
                                //   style: BodyTextStyle
                                // ),
                              //),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                        //width: 400,
                        padding: EdgeInsets.only(bottom: 10, right: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (event.signup_url != null) ...[
                                ElevatedButton.icon(
                                  onPressed: () {
                                    launchUrl(Uri.parse(event.signup_url!));
                                  },
                                  label: Text( 'Anmelden'),
                                  icon: Icon(Icons.check),
                                ),
                              ],
                            ])),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}

//TODO: 
// - Cancel search on back
// - Dont show search when switchting screens
AppBarWithSearchSwitch appBarEvents(
    BuildContext context, ValueNotifier<String> searchText) {
  return AppBarWithSearchSwitch(
    onChanged: (text) => searchText.value = text,
    clearOnClose: true,
    fieldHintText: 'Suchen',
    appBarBuilder: (context) {
      return AppBar(
        title: Text('Anlässe'),
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
