import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentScreen extends StatefulWidget {
  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final _searchText = ValueNotifier<String>('');

  // PDFs
  final List<Map<String, String>> _pdfs = [
    {'name': 'Biercomment', 'path': 'assets/pdfs/Biercomment.pdf'},
    {'name': 'Statuten Aktivitas', 'path': 'assets/pdfs/StatutenAktivitas.pdf'},
  ];

  // Links
  final List<Map<String, String>> _links = [
    {'name': 'Commercia Webseite', 'url': 'https://commercia-aarau.ch'},
    {
      'name': 'Verein Aarauer Verbindungen',
      'url': 'https://www.verein-aarauer-verbindungen.ch/'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarDocuments(context, _searchText),
      body: Center(
        child: Container(
          width: 600,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              Text('PDFs', style: Theme.of(context).textTheme.titleLarge),
              ..._pdfs.map((pdf) => ListTile(
                    leading: Icon(Icons.picture_as_pdf),
                    title: Text(pdf['name']!),
                    onTap: () {
                      Map<String, dynamic> data = {
                        'name': pdf['name'],
                        'path': pdf['path'],
                      };
                      context.pushNamed(
                        'pdf',
                        extra: data,
                      );
                    },
                  )),
              SizedBox(height: 24),
              Text('Links', style: Theme.of(context).textTheme.titleLarge),
              ..._links.map((site) => ListTile(
                    leading: Icon(Icons.language),
                    title: Text(site['name']!),
                    subtitle: Text(site['url']!),
                    onTap: () async {
                      final url = Uri.parse(site['url']!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url,
                            mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Link kann nicht geöffnet werden')),
                        );
                      }
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

AppBarWithSearchSwitch appBarDocuments(
    BuildContext context, ValueNotifier<String> searchText) {
  return AppBarWithSearchSwitch(
    onChanged: (text) => searchText.value = text,
    clearOnClose: true,
    appBarBuilder: (context) {
      return AppBar(
        title: Text('Dokumente'),
        actions: [
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
