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
                    height: 300,
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
                        // Date & time + Treffpunkt — combined card
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Card(
                            elevation: 0,
                            color: Theme.of(context).colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              child: Column(
                                children: [
                                  // Date & time row
                                  Row(
                                    children: [
                                      Icon(Icons.event,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          size: 28),
                                      SizedBox(width: 16),
                                      Text(
                                        event.date_long!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  // Treffpunkt row
                                  if (event.location_meet != null &&
                                      event.location_meet!.isNotEmpty) ...[
                                    Divider(
                                      height: 24,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2.0),
                                          child: Icon(Icons.place_outlined,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              size: 26),
                                        ),
                                        SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Treffpunkt",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 1.1,
                                                    ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                event.card_text!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Location
                        if (event.location != null) ...[
                        ListTile(
                          leading: Icon(Icons.location_on),
                          title: Text(event.location!),
                          subtitle: Text(event.location_details!),
                        ), ],
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
    automaticallyImplyLeading: false,
    actions: [
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => GoRouter.of(context).pop(),
      ),
    ],
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
              startTime: event.start_dt!,
              endTime: event.end_dt!,
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