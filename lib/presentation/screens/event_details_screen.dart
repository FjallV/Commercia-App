import 'package:commercia/business/ics.dart';
import 'package:commercia/data/models/event_model.dart';
import 'package:commercia/presentation/widgets/screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetails extends StatelessWidget {
  EventDetails({super.key, required this.event});
  EventModel event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBarEventDetails(context, event.title),
      bottomNavigationBar: bottomAppBar(event),
      body: SingleChildScrollView(
        //Center(
        child: Align(
          alignment: Alignment.topCenter,
          child: Center(
            //SingleChildScrollView(
            child: Container(
              width: 600,
              child: Column(
                children: [
                  Container(
                    //TODO height/width ratio -> Fit
                    height: 300,
                    //width: 600,
                    child: Hero(
                        tag: event.id,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                alignment: Alignment.topCenter,
                                //image: NetworkImage(event.image!),
                                image: AssetImage(event.image!),
                                fit: BoxFit.cover),
                          ),
                        )),
                  ),
                  ListView(
                      padding: EdgeInsets.all(10),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        // Title and subtitle
                        if (event.subtitle != '' && event.subtitle != null) ...[
                          ListTile(
                            //leading: Icon(Icons.calendar_today_outlined),
                            title: Text(event.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 24)),
                            subtitle: Text(event.subtitle!,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 18)),
                          ),
                        ] else ...[
                          ListTile(
                            //leading: Icon(Icons.calendar_today_outlined),
                            title: Text(event.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 24)),
                          ),
                        ],
                        if (event.location_meet != null &&
                            event.location_meet!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              child: Row(
                                children: [
                                  Icon(Icons.meeting_room,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      event.card_text!,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Date & time
                        ListTile(
                          //TODO Gap?
                          //horizontalTitleGap: 30,
                          leading: Icon(Icons.schedule_outlined),
                          title: Text(event.date_long!),
                          subtitle: Text(event.time_text!),
                        ),
                        // Location
                        ListTile(
                          leading: Icon(Icons.place_outlined),
                          title: Text(event.location!),
                          subtitle: Text(event.location_details!),
                        ),
                        // Meeting point
                        //                         ListTile(
                        //   leading: ImageIcon(
                        //     AssetImage("assets/icons/event_meet2.png"),
                        //     //color: Colors.black,
                        //     //color: Theme.of(context).colorScheme.onSurface,
                        //     size: 24,
                        //   ),
                        //   //leading: Icon(Icons.target),
                        //   title: Text(event.location_meet!),
                        //   subtitle: Text(event.time_meet!),
                        // ),

                        // Cost
                        if (event.cost_show == 'both') ...[
                          ListTile(
                            leading: Icon(Icons.payments_outlined),
                            title: Text(event.cost!),
                            subtitle: Text(event.cost_ak!),
                          ),
                        ] else if (event.cost_show == 'one') ...[
                          ListTile(
                            leading: Icon(Icons.payments_outlined),
                            title: Text(event.cost!),
                          ),
                        ],
                        //Tenue
                        ListTile(
                          leading: Icon(Icons.checkroom),
                          title: Text(event.tenue_text!),
                        ),
                        // Info
                        if (event.details != null) ...[
                          ListTile(
                            titleAlignment: ListTileTitleAlignment.titleHeight,
                            leading: Icon(Icons.info_outline),
                            title: Text(event.details!),
                          ),
                        ]
                      ])
                ],
              ),
            ),
          ),
        ),
      ),
      // ),
    );
  }
}

ListTile eventTile(String title, String subtitle, Icon icon) {
  return ListTile(
    leading: icon,
    title: Text(title),
    subtitle: Text(subtitle),
  );
}

AppBar appBarEventDetails(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
        icon: Icon(Icons.arrow_back),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(5),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        onPressed: () => GoRouter.of(context).pop()),
  );
}

BottomAppBar bottomAppBar(EventModel event) {
  return BottomAppBar(
    child: new Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.calendar_month),
          onPressed: () {
            final creator = ICSFileCreator(
              title: event.title,
              description: event.details ?? '',
              location: event.location!,
              startTime: DateTime.utc(
                  event.date!.year,
                  event.date!.month,
                  event.date!.day,
                  int.parse(event.time_start!.split(':')[0]),
                  int.parse(event.time_start!.split(':')[1])),
              endTime: DateTime.utc(
                  event.date!.year,
                  event.date!.month,
                  event.date!.day,
                  int.parse(event.time_end!.split(':')[0]),
                  int.parse(event.time_end!.split(':')[1])),
            );

            creator.downloadICSFile(creator.generateICSContent(),
                filename: event.title);

            //  SnackBar snackBar = SnackBar(
            //    content: Text('ICS file downloaded!'),
            //  );
            //snackBar.show(context);
          },
        ),
        if (event.signup_url != null) ...[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              launchUrl(Uri.parse(event.signup_url!));
            },
          ),
        ]
      ],
    ),
  );
}
